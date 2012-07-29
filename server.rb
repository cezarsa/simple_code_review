['apps', 'helpers', 'models'].each do |path|
  Dir["#{path}/*.rb"].each do |file|
    require_relative file
  end
end

class SimpleCodeReview < Sinatra::Base
  use Rack::Session::Cookie
  use Rack::MethodOverride

  configure do
    Mongoid.load!("config/mongoid.yml")
  end

  configure :development do
    register Sinatra::Reloader
    also_reload './models/*'
    also_reload './helpers/*'
    also_reload './apps/*'
  end

  use AuthApp
  helpers UserHelpers
  helpers UrlHelpers
  helpers TemplateHelpers

  get "/repository/new" do
    require_login!

    @repository = Repository.new

    erb :edit_repository
  end

  get "/:name_part1/:name_part2/config" do |part1, part2|
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    erb :edit_repository
  end

  post "/repository/update" do
    require_login!

    @repository = Repository.new(:url => params[:url].downcase,
                                 :owner => current_user_id,
                                 :min_score => params[:min_score],
                                 :cut_date => params[:cut_date])

    if @repository.save
      @repository.update_repository!
      redirect '/'
    else
      @errors = @repository.errors
      erb :edit_repository
    end
  end

  put "/repository/update" do
    require_login!

    halt 403 unless params[:id]
    @repository = Repository.find(params[:id])
    halt 403 unless current_user_id == @repository.owner.id

    if @repository.update_attributes(:min_score => params[:min_score],
                                    :cut_date => params[:cut_date])
      redirect '/'
    else
      @errors = @repository.errors
      erb :edit_repository
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

    filters = params[:filter].split(',') rescue nil
    @commits = @repository.filter_commits(filters, current_user)

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
