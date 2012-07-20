module UserHelpers
  def current_user
    @current_user = session[:user_id] && (@current_user || User.find(session[:user_id]))
  end

  def current_user_id
    session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login!
    redirect '/' unless logged_in?
  end
end
