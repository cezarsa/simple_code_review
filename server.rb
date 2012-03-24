require_relative "models/repository"

class SimpleCodeReview < Sinatra::Base

  configure do
    Mongoid.load!("models/mongoid.yml")
  end

  get "/" do
    repo = Repository.new(:url => 'git://github.com/globocom/thumbor.git')
    repo.save

    "Repo: #{repo.url}"
  end

end