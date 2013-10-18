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
        
        stub_request(:get, "#{dominio}robots.txt").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RoboYep'}).to_return({:content_type => "text"}, :status => [200, "OK"])
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
        @robo.paginas_extraidas.length.should == 1
      end
    end
    
    context "#salva_links" do
      it "should call save links in db" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        
        pagina.stub(links: pages[0].links_url, code: "200", :url => dominio)
        
        db.should_receive(:links).with(1).and_return([{"url" => dominio}])
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio).and_return(pagina) }
        pages.each { |page| db.should_receive(:save).with(pagina.links, dominio) }

        @robo = RoboLek.start(db, 1)
        @robo.crawl
        @robo.salva_links
      end
    end
    
    context "#loop_crawl" do
      it "should return links use deep 2 for crawl" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        pages << StubPage.new("#{dominio}teste1", "", :links => ['/teste3'])
        pages << StubPage.new("#{dominio}teste2", "", :links => [])

        db.should_receive(:links).with(100).and_return([{"url" => dominio}])
        
        @robo = RoboLek.start(db)
        
        pagina.stub(links: pages[0].links_url, code: "200", :url => dominio)
        TrataLink.should_receive(:trata_pagina).with(pages[0].dominio).and_return(pagina)
        db.should_receive(:save).with(pages[0].links_url, dominio)
        @robo.loop_crawl(:next)
      end
      
    end
  end
end