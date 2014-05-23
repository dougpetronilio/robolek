require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  DOMINIO = "http://www.teste.com/"
  DOMINIO_ERROR = "http://www.error.com/"
  DOMINIO_REDIRECIONAMENTO = "http://www.teste.com/teste"

  describe TrataLink do

    before(:each) do
      @page = StubPage.new(DOMINIO, "", opcoes = {:links => ['teste1', 'teste2']})
      @page_error = StubPage.new(DOMINIO_ERROR, "", opcoes = {:code => 400})
      @page_redirect = StubPage.new(DOMINIO_REDIRECIONAMENTO, "", opcoes = {:code => 301, :redirecionamento => DOMINIO})
    end

    context "#new" do
      it "should tratalink create a page" do
        Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url, nil, [])
        TrataLink.trata_pagina(DOMINIO, "#{DOMINIO}robots.txt", nil, nil, nil, nil)
      end

      it "should complete page with body, code and links" do
         Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url, nil, [])
         trata_link = TrataLink.trata_pagina(DOMINIO, "#{DOMINIO}robots.txt", nil, nil, nil, nil)
         trata_link.code.should == "200"
         trata_link.body.should == @page.body
         trata_link.links.should == @page.links_url
      end

      it "should pagina.links length be 2" do
        Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url, nil, [])
        trata_link = TrataLink.trata_pagina(DOMINIO, "#{DOMINIO}robots.txt", nil, nil, nil, nil)
        trata_link.links.length.should == 3
      end

      it "should code error and links length be 0" do
        Pagina.should_receive(:new).with(DOMINIO_ERROR, "400", "", [], nil, [])
        trata_link = TrataLink.trata_pagina(DOMINIO_ERROR, "#{DOMINIO}robots.txt", nil, nil, nil, nil)
        trata_link.code.should == "400"
        trata_link.links.length.should == 0
      end

      it "should redirect to link and extract links" do
        Pagina.should_receive(:new).with(DOMINIO, "200", @page.body, @page.links_url, nil, [])
        trata_link = TrataLink.trata_pagina(DOMINIO_REDIRECIONAMENTO, "#{DOMINIO}robots.txt", nil, nil, nil, nil)
        trata_link.links.length.should == 3
      end
    end
  end
end
