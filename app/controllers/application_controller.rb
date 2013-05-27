class ApplicationController < ActionController::Base
  before_filter :authorize
  before_filter :record_refer
  helper_method :validate_permission?
  helper_method :lend_books_count
  protect_from_forgery

protected
  def authorize
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      redirect_to login_url, :notice => "请登录！"
    end
  end

  def record_refer
    session[:prev_url] = request.referer
  end

  # edit permissoin
  # book => owners
  # reading => reader
  # user => user
  def validate_permission?(users)
    u = users.to_a.collect {|x| x.id}
    u.include?(session[:user_id])
  end

  def lend_books_count(user_id)
    user = User.find_by_id(user_id)
    user.readings.count(:conditions => "return_at is null")
  end
end
