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
