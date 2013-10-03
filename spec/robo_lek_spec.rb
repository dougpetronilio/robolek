require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe RoboLek do
    let(:db) { double("db").as_null_object }
    it "should have a version" do
      RoboLek.const_defined?('VERSION').should == true
    end
    
    it "should return RoboLek::Crawler instance" do
      robolek = RoboLek.start(db)
      robolek.should be_an_instance_of(RoboLek::Crawler)
    end
  end
end