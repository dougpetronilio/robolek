require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  DOMINIO = "http://www.teste.com/"
  DOMINIO_ERROR = "http://www.error.com/"
  
  describe TrataLink do
    
    before(:each) do
      @page = StubPage.new(DOMINIO, "", opcoes = {:links => ['teste1', 'teste2']})
      @page_error = StubPage.new(DOMINIO_ERROR, "", opcoes = {:code => 400})
    end
    
    context "#new" do
      it "should tratalink create a page" do
        Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url)
        TrataLink.trata_pagina(DOMINIO)
      end
      
      it "should complete page with body, code and links" do
         Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url)
         trata_link = TrataLink.trata_pagina(DOMINIO)
         trata_link.code.should == "200"
         trata_link.body.should == @page.body
         trata_link.links.should == @page.links_url
      end
      
      it "should pagina.links length be 2" do
        Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url)
        trata_link = TrataLink.trata_pagina(DOMINIO)
        trata_link.links.length.should == 2
      end
      
      it "should code error and links length be 0" do
        Pagina.should_receive(:new).with(DOMINIO_ERROR, "400", "", [])
        trata_link = TrataLink.trata_pagina(DOMINIO_ERROR)
        trata_link.code.should == "400"
        trata_link.links.length.should == 0
      end
    end
  end
end