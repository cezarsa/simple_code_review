$stdout.sync = true

require_relative "models/commit"
require_relative "models/user"
require_relative "models/review"
require_relative "models/repository"

class RepositoryUpdater

  @queue = :updater

  def self.perform
    Repository.all.each(&:update_repository!)
  end

end