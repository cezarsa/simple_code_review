require_relative "models/repository"

class SimpleCodeReview < Sinatra::Base

  configure do
    Mongoid.load!("models/mongoid.yml")
  end

  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    repo = Repository.where(:name => 'thumbor').first
    unless repo
      repo = Repository.new(:name => 'thumbor', :url => 'git://github.com/globocom/thumbor.git')
      repo.save!
    end

    git_repo = repo.git_repo

    "Repo: #{git_repo.commit_count} commits"
  end

end