require_relative 'spec_helper'

describe "Simple Code Review" do

  describe "as a non authenticated user" do

    describe "GET '/'" do

      it "should be accessible" do
        get '/' 
        last_response.should be_ok 
      end
      
    end

    describe "GET '/repository/new'" do

      it "should redirect to the home page" do
        get '/repository/new' 
        last_response.should be_redirect
        follow_redirect!
        # http://example.org/ === Rack test server name
        last_request.url.should == 'http://example.org/'
      end
      
    end

    describe "POST '/repository/update'" do

      it "should redirect to the home page" do
        post '/repository/update' 
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end
      
    end

    describe "PUT '/repository/update'" do

      it "should redirect to the home page" do
        put '/repository/update' 
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end
      
    end

    describe "GET '/mybad'" do

      it "should redirect to the home page" do
        get '/mybad' 
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end
      
    end

    describe "GET '/pending'" do

      it "should redirect to the home page" do
        get '/pending' 
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end
      
    end

    describe "GET '/mydiscussions'" do

      it "should redirect to the home page" do
        get '/mydiscussions' 
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://example.org/'
      end
      
    end

  end

  describe "as an authenticated user" do
  end

end
