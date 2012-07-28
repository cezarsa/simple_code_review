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

  def score
    reviews.where(type: :positive).count - reviews.where(type: :negative).count
  end

end
