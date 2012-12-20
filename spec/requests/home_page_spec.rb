require_relative '../acceptance_helper'

describe "Home page" do

  subject { page }

  before do
    @repo1 = FactoryGirl.create(:repository)
    @repo2 = FactoryGirl.create(:repository)
    visit "/"
  end

  it { html.should match '<title>Simple Code Review</title>' }
  it { should have_selector('h1', text: "Simple Code Review") }
  it { should have_selector('a', text: "Log in") }
  it { should have_selector('p', text: @repo1.url) }
  it { should have_selector('p', text: @repo2.url) }

  describe "as a non authenticated user" do
  end

  describe "as an authenticated user" do
  end

end