FactoryGirl.define do
  sequence :username do |n|
    "user_#{n}"
  end

  sequence :name do |n|
    "Person #{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    username { generate(:username)  }
    name { generate(:name)  }
    email { generate(:email)  }
    alternative_emails { [generate(:email) , generate(:email) ] }
    github_token "a123b"
    avatar_url "https://en.gravatar.com/userimage/5658385/091824b5852184e5838d98ebb3c28eb5.jpeg"
  end

  sequence :repository_name do |n|
    "Repository #{n}"
  end

  sequence :repository_url do |n|
    "git://github.com/daviferreira/repository_#{n}.git"
  end

  factory :repository do
    name { generate(:repository_name) }
    branch "master"
    url { generate(:repository_url) }
    min_score 2
    cut_date { 1.week.ago }
    last_updated { Time.now }
    association :owner, factory: :user
  end
end