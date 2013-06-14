# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  skip_before_filter :authorize, :only => [ :show, :new, :create, :find_password, :reset_password ]

  # GET /users
  # GET /users.xml
  def index
    # Do not show all the users except the login user

    # @users = User.paginate :page=>params[:page], :order=>'webid asc',
    #   :per_page => 20

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @users }
    # end

    redirect_to :controller => "users",
                :action => "show",
                :id => session[:user_id]
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    unless validate_permission?(@user)
      redirect_to(user_path(@user),
                  :notice => "无权编辑该用户信息！")
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    #@user.email+="@alcatel-lucent.com"

    respond_to do |format|
      if @user.save
        # send welcome email
        Mailer.welcome(@user).deliver

        format.html { redirect_to(users_url,
                                  :notice => 'User #{@user.id} was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(user_path(@user),
                                  :notice => "用户 #{@user.webid} 更新成功！") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])

    begin
      unless validate_permission?(@user)
        raise "无权删除该用户！"
      else
        @user.destroy
        flash[:notice] = "User #{@user.id} deleted"
      end
    rescue Exception => e
      flash[:notice] = e.message
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def find_password
  end

  def reset_password
    @user = User.find_by_webid(params[:webid])

    if @user.nil?
      redirect_to(find_password_path,
                  :alert => "该web id不存在！")
    elsif @user.email.nil?
      redirect_to(find_password_path,
                  :alert => "该用户邮箱信息错误，请联系管理员！")
    else
      password = rand(1000000).to_s[0, 6]
      @user.password = password

      unless @user.save
        redirect_to(find_password_path,
                    :alert => "用户 #{@user.webid} 密码重置失败！")
      else
        # send email with new password
        Mailer.reset_password(@user, password).deliver
        
        redirect_to(login_path,
                    :alert => "用户 #{@user.webid} 密码重置成功！")
      end
    end
  end

end
