class Repository
  include Mongoid::Document

  field :name, type: String
  field :url, type: String

  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :reviewers, :class_name => 'User'

  validates_presence_of :name, :url, :owner
  validates_uniqueness_of :name

  before_validation :generate_name

  def repo_path
    unless @repo_path
      slug = url.gsub(/^(git|https?)(:\/\/|@)/, '').gsub(/\/|:|\./, '-')
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
    git_repo.git.pull
    git_repo.log
  end

  def commit(hash)
    git_repo.commit(hash)
  end

  def generate_name
    return if self.name

    groups = url.match(%r{^(?:git|https?)(?:://|@).*?(?:/|:)(.*?)\..*})
    if groups
      self.name = groups[1]
    else
      self.name = url.match(%r{^(?:git|https?)(?:://|@).*?(?:/|:)(.*)})[1]
    end
  end

end
