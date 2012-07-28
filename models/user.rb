class User
  include Mongoid::Document

  field :username, type: String
  field :name, type: String
  field :email, type: String
  field :alternative_emails, type: Array
  field :github_token, type: String
  field :avatar_url, type: String

  has_many :owned_repositories, :inverse_of => :owner, :class_name => 'Repository'
  has_and_belongs_to_many :reviewer_repositories, :inverse_of => :reviewers, :class_name => 'Repository'

  validates_presence_of :username, :email
  validates_uniqueness_of :username, :email

  def self.create_or_update_user(github_data, emails)
    basic_info = github_data[:info]
    extra_info = github_data[:extra][:raw_info]
    credentials = github_data[:credentials]

    user = User.where(:email => basic_info[:email]).first
    unless user
      user = User.new(:username => basic_info[:nickname], :email => basic_info[:email])
    end
    user.update_attributes!({
      :github_token => credentials[:token],
      :name => basic_info[:name],
      :avatar_url => extra_info[:avatar_url],
      :alternative_emails => emails || [basic_info[:email]]
    })
    
    user
  end
end