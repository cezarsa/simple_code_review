require_relative "models/user"
require_relative "models/repository"

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

class AuthApp < Sinatra::Base
  use OmniAuth::Builder do
    provider :github, 'c3867515da369e35bbbe', '1c30a20aedd7777d6640234799a2d4c32418eece', scope: "user"
  end

  get '/auth/github/callback' do
    user = User.create_or_update_user(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect '/'
  end

  get '/logout' do
    session.delete :user_id
    redirect '/'
  end
end

class SimpleCodeReview < Sinatra::Base
  use Rack::Session::Cookie

  configure do
    Mongoid.load!("models/mongoid.yml")
  end

  configure :development do
    register Sinatra::Reloader
    also_reload './models/*'
  end

  use AuthApp
  helpers UserHelpers

  post "/repositories" do
    require_login!

    repo = Repository.new(:url => params[:url].downcase, :owner => current_user_id)
    if repo.save
      redirect '/'
    else
      @errors = repo.errors
      repositories_list
    end
  end

  get %r"^/(\w+/\w+)/(\w+)$" do |repository_name, commit_hash|
    @repository = Repository.where(:name => repository_name.downcase).first
    halt 404 unless @repository

    @commit = @repository.commit(commit_hash)
    halt 404 unless @commit

    erb :commit
  end

  get %r"^/(\w+/\w+)$" do |repository_name|
    @repository = Repository.where(:name => repository_name.downcase).first
    halt 404 unless @repository

    erb :commits
  end

  get "/" do
    repositories_list
  end

  def repositories_list
    @repositories = Repository.all
    erb :index
  end

end