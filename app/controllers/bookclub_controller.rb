# -*- coding: utf-8 -*-
class BookclubController < ApplicationController
  skip_before_filter :authorize, :except => [ :lend_book ]


  #this function is becoming ugly 
  #it is doing too many things
  def index
    @query_str = params[:query_str] || ""
    @category  = Category.find(params[:category]) if params[:category]
    @owner     = User.find(params[:owner]) if params[:owner]
    @reader    = User.find(params[:reader]) if params[:reader]
    conditions = "" 
    joins      = ""
    show_allbook = "no"
    show_allbook = "yes" if params.include?("show_all")
    show_suggest = "yes" if params.include?("show_suggest")
#print params

    # though currently @query_str, @owner or @reader excludes each other
    # below codes do not make them excluded
    if (!@query_str.nil? && !@query_str.empty?)
      # TODO: eliminate SQL Injection Attack
      conditions += " books.title like '%" + @query_str + "%'"
      show_allbook='yes'
    end

   #if ( show_allbook != "yes" )
#	    if show_suggest == "yes"
#		    conditions += "books.status like 'suggest'"
##	    else
#		    conditions += "( books.status is null or books.status not like 'suggest')"
#	    end
#    end

    if @owner
      joins +=   " inner join resources" +
                 " on resources.book_id = books.id" +
                 "   and resources.user_id = #{@owner.id}"
      #conditions +=" and resources.user_id = #{@owner.id} "
      order  =   " resources.id desc"
    end

    if @reader
      joins +=   " inner join readings" +
                 "   on readings.book_id = books.id" +
                 "   and readings.user_id = #{@reader.id}"
      order  =   " readings.id desc"
    end

    @categories = Category.all(
                    :select => " c.id, c.parent_id, c.name," +
                               " count(cb.category_id) as book_count",
                    :joins  => " as c left join categories_books as cb" +
                               "   on c.id = cb.category_id" +
                               " left join books as books" +
                               "   on books.id = cb.book_id" + joins,
                    :conditions => conditions,
                    :group => " c.id, c.parent_id, c.name")

    # when choose a @category, the total @categories above will not be impacted,
    # but the later @books will do.
    if @category
      if @category.id == 13
        show_allbook = "yes"
        conditions += " books.status like 'suggest'"
      else
        joins += " inner join categories_books" +
               "   on categories_books.book_id = books.id" +
               "   and categories_books.category_id = #{@category.id}"
      end
    end

    #if ! (show_allbook == "yes")
    #  conditions += " resources.total_quantity != 0 "
      #joins += " inner join resources" +
      #       "  on resources.book_id = books.id" +
      #       "  and resources.total_quantity != 0"
    #end


    @books = Book.paginate(:include => [ :rating, :resources ],
                           :select => " DISTINCT books.*",
                           :joins => joins,
                           :conditions => conditions,
                           :page => params[:page],
                           :order => order || " books.id desc ",
                           :per_page => 20)
  end

  def lend_book
    lend = params[:lend]

    begin
      self.send "lend_#{lend}" ||
        (@lend_msg = "Invalid parameter lend: #{params[:lend]}" && raise)
      @lend_msg ||= "操作成功！"
    rescue
      @lend_msg ||= "操作失败！"
    end

    respond_to do |format|
      flash[:notice] = @lend_msg
      format.html { redirect_to :controller => "readings",
                                :action => "manage" }
      format.xml  { render :xml => @reading }
    end
  end

protected
  def lend_lend_in(reserve = false)
    count = lend_books_count(session[:user_id])
    if count >= 2
      @lend_msg = "借阅不能超过两本！"
      raise
    end

    book = Book.find(params[:id])
    Resource.transaction do
      res = Resource.lock.first(:conditions => [ "book_id = ?",
                                                 book.id ],
                                :order => "current_quantity desc")
      unless res
        @lend_msg = "图书 #{book.id} 资源错误！"
        raise
      end

      res.current_quantity -= 1
      res.save

      time = Time.now
      @reading = Reading.new(:resource_id => res.id,
                             :book_id => book.id,
                             :user_id => session[:user_id],
                             :created_at => time,
                             :updated_at => time)
      @reading.save
    end

    reader = @reading.reader
    owner  = @reading.resource.owner

    if ! reserve
      Mailer.lend_in(reader, owner, book).deliver
    else
      current_readers = User.all(:select => "users.*",
                                 :joins  => "inner join readings" +
                                            "  on readings.user_id = users.id" +
                                            "    and readings.return_at is null",
                                 :conditions => [ "readings.book_id = ?",
                                                  book.id ])
      Mailer.lend_reserve(reader, owner, book, current_readers.to_a).deliver
    end
  end

  def lend_reserve
    lend_lend_in true
  end

  def lend_cancel
    @reading = Reading.find(params[:id],
                            :include => [ :reader, :book, :resource ])
    if @reading.user_id != session[:user_id]
      @lend_msg = "不能撤消他人的图书借阅！"
      raise
    elsif @reading.read_at
      @lend_msg = "不能撤消已经开始的图书借阅！"
      raise
    end

    if @reading.resource
      reader = @reading.reader
      book   = @reading.book
      owner  = @reading.resource.owner

      Resource.transaction do
        res = Resource.lock.first(:conditions => [ "id = ?",
                                                   @reading.resource_id ])
        res.current_quantity += 1
        res.save

        @reading.destroy
      end

      Mailer.lend_cancel(reader, owner, book).deliver
    else
      # when a reader cancel a reading whose resource does not exist
      # so destroy the reading only
      @reading.destroy
    end
  end

  def lend_return
    @reading = Reading.find(params[:id],
                            :include => :resource)
    if @reading.resource.user_id != session[:user_id]
      @lend_msg = "不能归还他人的图书！"
      raise
    elsif @reading.return_at
      @lend_msg = "不能归还已经归还的图书！"
      raise
    end

    Resource.transaction do
      res = Resource.lock.first(:conditions => [ "id = ?",
                                                 @reading.resource_id ])
      res.current_quantity += 1
      res.save

      @reading.return_at = Time.now
      @reading.save
    end

    reader = @reading.reader
    owner  = @reading.resource.owner
    book   = @reading.book
    Mailer.lend_return(reader, owner, book).deliver
  end

  def lend_lend_out
    @reading = Reading.find(params[:id],
                            :include => :resource)
    if @reading.resource.user_id != session[:user_id]
      @lend_msg = "不能借出他人的图书！"
      raise
    elsif @reading.read_at
      @lend_msg = "不能借出已经借出的图书！"
      raise
    elsif @reading.return_at
      @lend_msg = "不能借出，因为借阅已经完成！"
      raise
    end

    Resource.transaction do
      @reading.read_at = Time.now
      @reading.save
    end
  end
end
