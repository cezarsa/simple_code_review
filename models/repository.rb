class Repository
  include Mongoid::Document

  field :name, type: String
  field :url, type: String
  field :min_score, type: Integer, default: 2
  field :cut_date, type: DateTime

  has_many :commits
  belongs_to :owner, :inverse_of => :owned_repositories, :class_name => 'User'
  has_and_belongs_to_many :reviewers, :inverse_of => :reviewer_repositories, :class_name => 'User'

  scope :by_name, ->(name_part1, name_part2) { where(name: "#{name_part1}/#{name_part2}".downcase) }

  validates_presence_of :name, :url, :owner
  validates_uniqueness_of :name

  before_validation :generate_name

  def git_repo
    return @repo if @repo

    Grit::Git.with_timeout(0) do
        begin
          @repo = Grit::Repo.new(repo_path)
        rescue Grit::InvalidGitRepositoryError, Grit::NoSuchPathError
          gritgit = Grit::Git.new(repo_path)
          gritgit.clone({:depth => 100, :quiet => false, :verbose => true, :branch => 'master'}, url, repo_path)
          @repo = Grit::Repo.new(repo_path)
        end
    end

    @repo
  end

  def update_repository!
    Grit::Git.with_timeout(0) do
        git_repo.git.pull
        git_repo.log.each do |raw_commit|
          commit = commits.where(:commit_hash => raw_commit.id).first
          break if commit
          commit = Commit.new(:commit_hash => raw_commit.id,
              :committer_email => raw_commit.committer.email,
              :timestamp => raw_commit.date)
          commit.valid = commit.timestamp >= cut_date
          commits << commit
        end
        save!
    end
  end

  def update_commits!
    Grit::Git.with_timeout(0) do
        commits.each do |commit|
          commit.update_attributes(:valid => commit.timestamp >= cut_date)
        end
    end
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

    groups = url.match(%r{^(?:git|https?)(?:://|@).*?(?:/|:)(.*?)(?:\..*|)?$})
    if groups
      self.name = groups[1]
    else
      self.name = url.match(%r{^(?:git|https?)(?:://|@)(.*)})[1]
    end
  end

end
