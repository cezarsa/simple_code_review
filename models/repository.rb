class Repository
  include Mongoid::Document

  field :name, type: String
  field :url, type: String
  field :min_score, type: Integer, default: 2
  field :cut_date, type: DateTime

  embeds_many :commits
  belongs_to :owner, :inverse_of => :owned_repositories, :class_name => 'User'
  has_and_belongs_to_many :reviewers, :inverse_of => :reviewer_repositories, :class_name => 'User'

  scope :by_name, ->(name_part1, name_part2) { where(name: "#{name_part1}/#{name_part2}".downcase) }

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

  @@commits_filters = {
    :me => ->(c, u) { u && u.alternative_emails.include?(c.committer.email) },
    :notme =>  ->(c, u) { u && !u.alternative_emails.include?(c.committer.email) },
    :bad => ->(c, u) { c.score < 0 },
    :good => ->(c, u) { c.score >= min_score },
    :pending => ->(c, u) { c.score >= 0 and c.score < min_score }
  }

  def filter_commits(filters, user)
    commits.to_a.select do |commit|
      next false if cut_date && commit.commit_data.date < cut_date
      next true unless filters
      filters.all? do |filter|
        filter_func = @@commits_filters[filter.to_sym]
        filter_func ? instance_exec(commit, user, &filter_func) : true
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
