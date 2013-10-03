require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Crawler do
    context "#start" do
      let(:db) { double("db").as_null_object }
      it "should have links in list when start robolek" do
        
        db.should_receive(:links).with(1).and_return(["http://www.teste.com/"])
        
        RoboLek.start(db, 1).lista_de_links.length.should == 1
      end
    end
  end
end