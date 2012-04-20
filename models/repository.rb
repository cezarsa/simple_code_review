class Review
  include Mongoid::Document

  REVIEW_TYPES = {
    :positive => 'LGTM',
    :neutral => 'meh',
    :negative => 'Bad, very bad...'
  }

  field :type, type: Symbol
  field :message, type: String

  embedded_in :commit
  belongs_to :user

  validates_inclusion_of :type, :in => REVIEW_TYPES.keys

  def friendly_type
    REVIEW_TYPES[type]
  end

end

class Commit
  include Mongoid::Document

  field :commit_hash, type: String

  embedded_in :repository
  embeds_many :reviews

  validates_uniqueness_of :commit_hash

  def commit_data
    @commit_data = @commit_data || repository.git_repo.commit(commit_hash)
  end

  def message
    commit_data.message
  end

  def committer
    commit_data.committer
  end

  def diffs
    commit_data.diffs
  end

end

class Repository
  include Mongoid::Document

  field :name, type: String
  field :url, type: String

  embeds_many :commits
  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :reviewers, :class_name => 'User'

  validates_presence_of :name, :url, :owner
  validates_uniqueness_of :name

  before_validation :generate_name

  def git_repo
    return @repo if @repo

    begin
      @repo = Grit::Repo.new(repo_path)
    rescue Grit::InvalidGitRepositoryError, Grit::NoSuchPathError
      gritgit = Grit::Git.new(repo_path)
      gritgit.clone({:quiet => false, :verbose => true, :branch => 'master'}, url, repo_path)
      @repo = Grit::Repo.new(repo_path)
    end
    @repo
  end

  def update_repository!
    git_repo.git.pull
    git_repo.log.each do |raw_commit|
      commit = commits.where(:commit_hash => raw_commit.id).first
      break if commit
      commits << Commit.new(:commit_hash => raw_commit.id)
    end
    save!
  end

protected

  def repo_path
    unless @repo_path
      slug = url.gsub(/^(git|https?)(:\/\/|@)/, '').gsub(/\/|:|\./, '-')
      @repo_path = "/tmp/#{slug}"
    end
    return @repo_path
  end

  def generate_name
    return if self.name
    return if self.url.empty?

    groups = url.match(%r{^(?:git|https?)(?:://|@).*?(?:/|:)(.*?)\..*})
    if groups
      self.name = groups[1]
    else
      self.name = url.match(%r{^(?:git|https?)(?:://|@)(.*)})[1]
    end
  end

end
