class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
  end

  def create
    if user = User.authenticate(params[:webid], params[:password])
      session[:user_id] = user.id
      uri = session[:original_uri]
      session[:original_uri] = nil

      redirect_to(uri || bookclub_url)
    else
      redirect_to login_url, :alert => "无效的用户名／密码组合！"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to bookclub_url, :notice => "成功注销！"
  end
end
