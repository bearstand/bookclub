# -*- coding: utf-8 -*-
class BooksController < ApplicationController
  skip_before_filter :authorize, :only => [ :show ]

  def index
    manage

    ## below code will show all books
    # @books = Book.paginate :page=>params[:page], :order=>'id asc',
    #   :per_page => 20

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @books }
    # end
  end

  def show
    @book = Book.find(params[:id],
                      :include => [ :owners ])
    
    @readings = Reading.paginate(:conditions => [ "book_id = ?",
                                                  @book.id
                                                ],
                                 :include => [ :reader ],
                                 :page => params[:page],
                                 :order => 'id asc',
                                 :per_page => 20)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @book }
    end
  end

  def new
    @book = Book.new(params[:product])
    @category_options = Category.all
    @category = nil

    flash[:suggest]='1' if params[:suggest]=="1"
    puts "new book"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end

  def edit
    @book = Book.find(params[:id],
                      :include => :categories)
    @category_options = Category.all
    @category = @book.categories.first

    unless validate_permission?(@book.owners)
      redirect_to(book_path(@book),
                  :notice => "无权编辑该图书信息！")
    end
  end

  def create
    @book = Book.new(params[:book])
    category = Category.find_by_id(params[:book_category])
    @book.categories << category

    puts "create book"
    puts "parms #{flash[:suggest]}"
    respond_to do |format|
      # for book be suggested(category id is 13) to buy, set quantity to zero
      if add_book(flash[:suggest] =="1" )

        format.html { redirect_to(@book, :notice => "新书添加成功！") }
        format.xml  { render :xml => @book, :status => :created, :location => @book }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @book = Book.find(params[:id])

    respond_to do |format|
      if @book.update_attributes(params[:book])
        category = Category.find_by_id(params[:book_category])
        if @book.categories.first != category
          @book.categories.clear
          @book.categories << category

          # if a book's category is updated to 13 (suggested to buy),
          # then its resources should be cleared
          if category.id == 13
            @book.resources.each do |r|
              # destroy readings of this resource, since they are invalid
              r.readings.each do |reading|
                reading.destroy
              end
              r.destroy
            end
          end

          @book.save
        end

        format.html { redirect_to(@book, :notice => "图书更新成功！") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # set the total_quantity of resource to 0,
  # not really delete the book
  def destroy
    @book = Book.find(params[:id])
    # @book.destroy
    resource = Resource.first(:conditions => [ "user_id = ? and book_id = ?",
                                               session[:user_id],
                                               @book.id ])
    resource.delete

    respond_to do |format|
      format.html { redirect_to(books_url) }
      format.xml  { head :ok }
    end
  end

  def manage
    user_id = session[:user_id]

    if user_id
      @owner = User.find_by_id(user_id)
      @books = @owner.books.paginate(:include => :rating,
                                     :page => params[:page],
                                     :order => 'id desc',
                                     :per_page => 20)
    end
    render :action => "index"
  end

  def i_have_one
    @book = Book.find(params[:id])

    add_book
    redirect_to :action => "index"
  end

protected
  def add_book(suggest=false)
    book_id = nil

    if @book.isbn.nil? || @book.isbn.empty?
      book = Book.find(:first, :conditions => [ "title = ?",
                                                @book.title ])
    else
      book = Book.find(:first, :conditions => [ "title = ? and isbn = ?",
                                                @book.title, @book.isbn ])
    end

    # book already exists
    # 1. the user already has a resource of the book
    # 2. a new resource needs be create
    if book
      resource = Resource.find(:first, :conditions => [ "book_id = ? and ( user_id = ? or total_quantity=0)",
                                book.id, session[:user_id] ])
      puts resource
      book_id = book.id
      if  book.status == "suggest" 
        book.status = "added"
        book.save
      end
    else
      @book.status="suggest" if suggest 
      unless @book.save
        return false
      end
      book_id = @book.id
    end

    # add resource only when it is not suggested book

    if suggest 
        resource = Resource.new(:user_id => session[:user_id],
                                :book_id => book_id,
                                :current_quantity => 0,
                                :total_quantity => 0)

    else
      if resource
        if  resource.total_quantity==0
          resource.user_id=session[:user_id]
        end
        resource.current_quantity += 1
        resource.total_quantity   += 1
      else
        resource = Resource.new(:user_id => session[:user_id],
                                :book_id => book_id,
                                :current_quantity => 1,
                                :total_quantity => 1)
      end
    end

    resource.save

    if suggest
        time = Time.now
        sugg = Reading.new(:resource_id => resource.id,
                           :book_id => book_id,
                           :user_id => session[:user_id],
                           :created_at => time,
                           :updated_at => time,
                           :read_at => time,
                           :return_at => time,
                           :status=>"suggest")
        sugg.save
    end

    return true
  end
end
