require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe DBMongo do
    before(:each) do
      @db_mongo = RoboLek.DBMongo
    end

    after(:each) do
      @db_mongo.clean
      @db_mongo.close
    end
    
    context "#new" do
      it "should return Mongo::DB when start Db" do
        @db_mongo.should be_an_instance_of(RoboLek::DBMongo)
      end
    end
    
    context "#links" do
      it "should return a list of array" do
        dominio = "http://www.teste.com/"
        @db_mongo.insert({:url => dominio})
        @db_mongo.links(1).count.should == 1
        @db_mongo.links(1).first["url"].should == dominio
      end
    end
    
    context "#save" do
      it "should return data from mongo" do
        dominio = "http://www.teste.com/"
        @db_mongo.save([dominio, "#{dominio}teste1"])
        paginas = @db_mongo.links(10)
        paginas.count.should == 2
        paginas.first["url"].should == dominio
        paginas.next["url"].should == "#{dominio}teste1"
      end
    end
  end
end