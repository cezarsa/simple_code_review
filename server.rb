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
    register Sinatra::StaticAssets
  end

  configure :development do
    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG

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

  post "/repository/update" do
    require_login!

    @repository = Repository.new(:url => params[:url].downcase,
                                 :branch => params[:branch].downcase,
                                 :owner => current_user_id,
                                 :min_score => params[:min_score],
                                 :cut_date => params[:cut_date])

    if @repository.save
      @repository.update_repository!
      redirect url('/')
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
      @repository.update_commits!
      redirect url('/')
    else
      @errors = @repository.errors
      erb :edit_repository
    end
  end

  get "/:name_part1/:name_part2/config" do |part1, part2|
    require_login!
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    erb :edit_repository
  end

  post "/:name_part1/:name_part2/:commit_hash/review" do |part1, part2, commit_hash|
    require_login!

    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @commit = @repository.commits.where(:commit_hash => commit_hash).first
    halt 404 unless @commit

    @commit.add_review(Review.new(:user => current_user_id, :message => params[:message], :type => params[:type]))

    if @commit.save
      redirect url("#{commit_url(@commit)}#reviews")
    else
      @errors = @commit.errors
      erb :commit
    end
  end

  post "/:name_part1/:name_part2/:commit_hash/fix" do |part1, part2, commit_hash|
    require_login!

    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @commit = @repository.commits.where(:commit_hash => commit_hash).first
    halt 404 unless @commit

    @commit.fix(current_user)

    if @commit.save
      redirect url(commit_url(@commit))
    else
      @errors = @commit.errors
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

  get "/mybad" do
    require_login!

    @commits = Commit.mybad(current_user)

    erb :commits
  end

  get "/pending" do
    require_login!

    Repository.all.each(&:update_if_necessary!)
    @commits = Commit.pending_for_me(current_user).order_by('timestamp DESC')

    erb :commits
  end

  get "/mydiscussions" do
    require_login!

    @commits = Commit.mydiscussions(current_user).order_by('timestamp DESC')

    erb :commits
  end

  get "/:name_part1/:name_part2" do |part1, part2|
    @repository = Repository.by_name(part1, part2).first
    halt 404 unless @repository

    @repository.update_repository!
    @commits = @repository.commits.valid.order_by('timestamp DESC')

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
