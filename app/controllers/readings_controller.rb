class ReadingsController < ApplicationController
  skip_before_filter :authorize, :only => [ :show ]

  def index
    @readings = Reading.paginate(:include => [ :book, :reader ],
                                 :conditions => "(book_id is not null) and ( readings.status!='suggest' or readings.status is null )",
                                 :page=>params[:page],
                                 :order=>'read_at asc',
                                 :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @readings }
    end
  end

  def edit
    @reading = Reading.find(params[:id])
    unless validate_permission?(@reading.reader)
      redirect_to(readings_manage_path,
                  :notice => "无权编辑该借阅信息！")
    end
  end

  def show
    @reading = Reading.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reading }
    end
  end

  def update
    @reading = Reading.find(params[:id])

    respond_to do |format|
      if @reading.update_attributes(params[:reading])
        format.html { redirect_to(readings_manage_path, :notice => '借阅更新成功！') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reading.errors, :status => :unprocessable_entity }
      end
    end
  end 

  def destroy
    @reading = Reading.find(params[:id])
    @reading.destroy

    respond_to do |format|
      format.html { redirect_to session[:prev_url] }
      format.xml  { head :ok }
    end
  end

  def manage
    user_id = session[:user_id]
    if user_id
      @reader = User.find_by_id(user_id)
      @in_readings = Reading.find(:all,
                                  :conditions => [ "(book_id is not null) and (status != 'suggest' or status is null) and" +
                                                   " user_id = ?", user_id ],
                                  :include => [ :book, :resource ],
                                  :order => 'read_at desc')

      @out_readings = Reading.find(:all,
                                   :select => "r.*",
                                   :joins => " as r inner join resources as res" +
                                             " on res.id = r.resource_id",
                                   :conditions => [ "r.book_id is not null and (status != 'suggest'  or status is null ) and" +
                                                    " res.user_id = ?", user_id ],
                                   :include => [ :book, :reader ],
                                   :order => 'updated_at desc')

      respond_to do |format|
        format.html # manage.html.erb
        format.xml  { render :xml => @readings }
      end
    end
  end
end
