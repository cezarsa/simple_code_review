require_relative "models/repository"

class SimpleCodeReview < Sinatra::Base

  configure do
    Mongoid.load!("models/mongoid.yml")
  end

  configure :development do
    register Sinatra::Reloader
    also_reload './models/*'
  end

  post "/repositories" do
    repo = Repository.new(:name => params[:name].downcase, :url => params[:url].downcase)
    if repo.save
      redirect '/'
    else
      @errors = repo.errors
      repositories_list
    end
  end

  get(/\/(\w+)\/(\w+)$/) do |repository_name, commit_hash|
    show_commit_diff(repository_name, commit_hash)
  end

  get(/\/(\w+)$/) do |repository_name|
    list_repository_commits(repository_name)
  end

  get "/" do
    repositories_list
  end

  def show_commit_diff(repository_name, commit_hash)
    @repository = Repository.where(:name => repository_name.downcase).first
    @commit = @repository.commit(commit_hash)

    erb :commit
  end

  def list_repository_commits(repository_name)
    @repository = Repository.where(:name => repository_name.downcase).first
    halt 404 unless @repository

    erb :commits
  end

  def repositories_list
    @repositories = Repository.all
    erb :index
  end

end