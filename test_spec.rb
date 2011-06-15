require 'rubygems'
require 'rspec'
require 'kimoto_censored'

describe KimotoCensored, "test" do
  before do
    @c = KimotoCensored.new
  end

  it "is positive sentence" do
    @c.is_positive_sentence("楽しい").should == true
    @c.is_positive_sentence("死ぬ").should == false
    @c.is_positive_sentence("楽しいけど死ぬ").should == true
  end

  it "is negative sentence" do
    @c.is_negative_sentence("死ぬ").should == true
    @c.is_negative_sentence("美しい").should == false
    @c.is_negative_sentence("楽しいけど死ぬ").should == false
  end

  it "cencored" do
    # name / organization name
    @c.kimoto_censored("kimotoという男が、googleのサーバーを破壊した").should == "Kという男が、Gのサーバーを破壊した"
    @c.kimoto_censored("きもとという男が、googleのサーバーを破壊した").should == "Kという男が、Gのサーバーを破壊した"
    @c.kimoto_censored("キモトという男が、googleのサーバーを破壊した").should == "Kという男が、Gのサーバーを破壊した"
    @c.kimoto_censored("山田という男が、googleのサーバーを破壊した").should == "Yという男が、Gのサーバーを破壊した"

    # daimeisi / org name
    @c.kimoto_censored("おっさんが近所のロッテリアでポケモン勝負をしていました").should == "おっさんが近所のRでポケモン勝負をしていました"

    # no name
    @c.kimoto_censored("そうなんですか").should == "そうなんですか"
    @c.kimoto_censored("勉強になります").should == "勉強になります"
    @c.kimoto_censored("rubyについて教えてください").should == "Rについて教えてください"
  end

  it "not implemented" do
    @c.is_positive_sentence("楽しいわけない").should == true
  end

  after do
    @c = nil
  end
end

