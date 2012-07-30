class Review
  include Mongoid::Document

  REVIEW_TYPES = {
    :positive => '+1',
    :neutral => '',
    :negative => '-1'
  }

  field :type, type: Symbol
  field :message, type: String
  field :timestamp, type: DateTime, default: -> { DateTime.now }

  embedded_in :commit
  belongs_to :user

  validates_inclusion_of :type, :in => REVIEW_TYPES.keys

  validates_presence_of :message, :if => -> { type == :neutral }

  def friendly_type
    REVIEW_TYPES[type]
  end

end
