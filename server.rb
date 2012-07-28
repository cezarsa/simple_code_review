['apps', 'helpers', 'models'].each do |path|
  Dir["#{path}/*.rb"].each do |file|
    require_relative file
  end
end

class SimpleCodeReview < Sinatra::Base
  use Rack::Session::Cookie

  configure do
    Mongoid.load!("config/mongoid.yml")
  end

  configure :development do
    register Sinatra::Reloader
    also_reload './models/*'
  end

  use AuthApp
  helpers UserHelpers
  helpers UrlHelpers
  helpers TemplateHelpers

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

  post "/:name_part1/:name_part2/:commit_hash/review" do |part1, part2, commit_hash|
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @commit = @repository.commits.where(:commit_hash => commit_hash).first
    halt 404 unless @commit

    @commit.reviews << Review.new(:user => current_user_id, :message => params[:message], :type => params[:type])

    if @repository.save
      redirect commit_url(@commit)
    else
      @errors = repo.errors
      erb :commit
    end
  end

  get "/:name_part1/:name_part2/:commit_hash" do |part1, part2, commit_hash|
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @commit = @repository.commits.where(:commit_hash => commit_hash).first
    halt 404 unless @commit

    erb :commit
  end

  get "/:name_part1/:name_part2" do |part1, part2|
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @repository.update_repository!
    @commits = @repository.commits.all

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
