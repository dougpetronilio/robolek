require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Pagina do
    
    before(:each) do
      @produto = Produto.new(DOMINIO, "200", "body")
    end
    
    context "#new" do
      it "should be a RoboLek::Pagina" do
        @produto.should be_an_instance_of(RoboLek::Produto)
      end
      
      it "should reader dominio, code, body and links" do
        @produto.dominio.should == DOMINIO
        @produto.code.should == "200"
        @produto.body.should == "body"
      end
    end
  end
end