class Commit
  include Mongoid::Document

  field :commit_hash, type: String
  field :branch, type: String
  field :committer_email, type: String
  field :timestamp, type: DateTime
  field :score, type: Integer, default: 0

  field :valid, type: Boolean
  field :status, type: Symbol, default: :pending

  belongs_to :user_responsible, :class_name => 'User'
  belongs_to :repository
  embeds_many :reviews

  validates_uniqueness_of :commit_hash, :scope => :branch

  scope :valid, -> { where(valid: true) }
  scope :from_user, ->(user) { where(:committer_email.in => user.alternative_emails) }
  scope :without_review_from, ->(user) { where("reviews.user_id".to_sym.ne => Moped::BSON::ObjectId(user.id)) }

  scope :bad, -> { where(:status => :bad, :user_responsible => nil) }
  scope :pending, -> { where(:status => :pending, :user_responsible => nil) }
  scope :good, -> { where(:status => :good, :user_responsible => nil) }

  scope :pending_for_me, ->(user) do
    valid.pending.without_review_from(user).not.from_user(user)
  end

  scope :mybad, ->(user) do
    valid.bad.from_user(user)
  end

  scope :mydiscussions, ->(user) do
    valid.where({ :status.ne => :good, :user_responsible => nil }).not.from_user(user).without_review_from(user)
  end

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

  def fix(user)
    reviews << Review.new(:user => user.id, :message => "Marked as fixed", :type => :neutral)
    self.user_responsible = user
  end

  def add_review(review)
    inc =
      case review.type
      when :positive
        1
      when :negative
        -1
      else
        0
      end

    self.score += inc
    self.status = 
      if self.score < 0
        :bad
      elsif score < repository.min_score
        :pending
      else
        :good
      end

    reviews << review
  end

end
