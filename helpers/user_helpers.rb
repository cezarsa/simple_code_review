module UserHelpers
  def current_user
    user_id = session[:user_id]

    return nil unless user_id
    return @current_user if @current_user

    begin
      @current_user = User.find(user_id)
    rescue
      session.delete(:user_id)
      nil
    end
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
