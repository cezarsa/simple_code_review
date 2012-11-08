class AuthApp < Sinatra::Base
  use OmniAuth::Builder do
    provider :github, ENV['SCR_GITHUB_KEY'], ENV['SCR_GITHUB_SECRET'], scope: "user"
  end

  get '/auth/github/callback' do
    alternative_emails = request.env['omniauth.strategy'].emails
    user = User.create_or_update_user(request.env['omniauth.auth'], alternative_emails)
    session[:user_id] = user.id

    redirect '/'
  end

  get '/logout' do
    session.delete :user_id

    redirect '/'
  end
end
