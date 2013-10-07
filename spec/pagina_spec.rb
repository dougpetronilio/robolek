require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Pagina do
    DOMINIO = "http://www.teste.com/"
    
    before(:each) do
      @pagina = Pagina.new(DOMINIO, "200", "body", ["link1", "link2"])
    end
    
    context "#new" do
      it "should be a RoboLek::Pagina" do
        @pagina.should be_an_instance_of(RoboLek::Pagina)
      end
      
      it "should reader dominio, code, body and links" do
        @pagina.dominio.should == DOMINIO
        @pagina.code.should == "200"
        @pagina.body.should == "body"
        @pagina.links.should have(2).String
      end
    end
  end
end