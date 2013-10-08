require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Crawler do
    let(:db) { double("db").as_null_object }
    let(:trata_link) { double("tratalink").as_null_object }
    let(:pagina) { double("pagina").as_null_object }

    context "#start" do      
      it "should have links in list when start robolek" do
        dominio = "http://www.teste.com/"
        db.should_receive(:links).with(1).and_return([{"url" => dominio}])
        TrataLink.should_receive(:trata_pagina).with(dominio)
        
        @robo = RoboLek.start(db, 1)
        @robo.crawl
        @robo.lista_de_links.length.should == 1
      end
    end
    
    context "#crawl" do
      it "should return page extract" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])

        db.should_receive(:links).with(1).and_return([{"url" => dominio}])
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio).and_return(trata_link) }
        
        @robo = RoboLek.start(db, 1)
        @robo.crawl
        @robo.paginas_extraidas.length.should == 1
      end
      
      it "should return two page extract" do
        dominio = "http://www.teste.com/"
        dominio2 = "http://www.outro.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        pages << StubPage.new(dominio2, "", :links => ['teste1'])

        db.should_receive(:links).with(1).and_return([{"url" => dominio}, {"url" => dominio2}])
        
        pagina.stub(links: pages[0].links_url)
        trata_link.stub(pagina: pagina)
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(page.dominio).and_return(trata_link) }
        
        @robo = RoboLek.start(db, 1)
        @robo.crawl
        @robo.paginas_extraidas.length.should == 2
      end
    end
    
    context "#salva_links" do
      it "should call save links in db" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        
        pagina.stub(links: pages[0].links_url)
        
        db.should_receive(:links).with(1).and_return([{"url" => dominio}])
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio).and_return(pagina) }
        pages.each { |page| db.should_receive(:save).with(page.links_url) }

        @robo = RoboLek.start(db, 1)
        @robo.crawl
        @robo.salva_links
      end
    end
  end
end