
class Repository
  include Mongoid::Document

  field :name, type: String
  field :url, type: String

  validates_presence_of :name
  validates_presence_of :url
  validates_uniqueness_of :name

  def repo_path
    unless @repo_path
      slug = url.gsub(/^(git:\/\/|https?:\/\/)/, '').gsub(/\/|:|\./, '-')
      @repo_path = "/tmp/#{slug}"
    end
    return @repo_path
  end

  def git_repo
    begin
      repo = Grit::Repo.new(repo_path)
    rescue Grit::InvalidGitRepositoryError, Grit::NoSuchPathError
      gritgit = Grit::Git.new(repo_path)
      gritgit.clone({:quiet => false, :verbose => true, :branch => 'master'}, url, repo_path)
      repo = Grit::Repo.new(repo_path)
    end
    repo
  end

  def commits
    git_repo.log
  end

  def commit(hash)
    git_repo.commit(hash)
  end
end