require 'spec_helper'

describe "URL validation", Perfectline::ValidatesUrl::Rails3::UrlValidator do

  context "with regular validator" do
    before do
      @user = User.new
    end

    it "should not allow nil as url" do
      @user.homepage = nil
      @user.should_not be_valid
    end

    it "should not allow blank as url" do
      @user.homepage = ""
      @user.should_not be_valid
    end

    it "should not allow an url without scheme" do
      @user.homepage = "www.example.com"
      @user.should_not be_valid
    end

    it "should allow an url with http" do
      @user.homepage = "http://localhost"
      @user.should be_valid
    end

    it "should allow an url with https" do
      @user.homepage = "https://localhost"
      @user.should be_valid
    end

  end

  context "with allow nil" do
    before do
      @user = UserWithNil.new
    end

    it "should allow nil as url" do
      @user.homepage = nil
      @user.should be_valid
    end

    it "should not allow blank as url" do
      @user.homepage = ""
      @user.should_not be_valid
    end

    it "shoild allow a valid url" do
      @user.homepage = "http://www.example.com"
      @user.should be_valid
    end
  end

  context "with allow blank" do
    before do
      @user = UserWithBlank.new
    end

    it "should allow nil as url" do
      @user.homepage = nil
      @user.should be_valid
    end

    it "should allow blank as url" do
      @user.homepage = ""
      @user.should be_valid
    end

    it "should allow a valid url" do
      @user.homepage = "http://www.example.com"
      @user.should be_valid
    end
  end

  context "with legacy syntax" do
    before do
      @user = UserWithLegacySyntax.new
    end

    it "should allow nil as url" do
      @user.homepage = nil
      @user.should be_valid
    end

    it "should allow blank as url" do
      @user.homepage = ""
      @user.should be_valid
    end

    it "should allow a valid url" do
      @user.homepage = "http://www.example.com"
      @user.should be_valid
    end

    it "should not allow invalid url" do
      @user.homepage = "random"
      @user.should_not be_valid
    end
  end

end