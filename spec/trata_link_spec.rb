require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  DOMINIO = "http://www.teste.com/"
  describe TrataLink do
    let(:pagina) { double("pagina") }
    
    context "#new" do
      it "should tratalink create a page" do
        page = StubPage.new(DOMINIO, "", :links => ['teste1', 'teste2'])
        Pagina.should_receive(:new).with(DOMINIO, "200", page.body, page.links_url)
        TrataLink.trata_pagina(DOMINIO)
      end
      
      it "should complete page with body, code and links" do
        
      end
    end
  end
end