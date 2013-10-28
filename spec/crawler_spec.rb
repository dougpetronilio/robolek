require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Crawler do
    let(:db) { double("db").as_null_object }
    let(:trata_link) { double("tratalink").as_null_object }
    let(:pagina) { double("pagina").as_null_object }
    let(:produto) { double("produto").as_null_object }
    let(:db_sql) { double("db_sql").as_null_object }

    context "#start" do      
      it "should have links in list when start robolek" do
        dominio = "http://www.teste.com/"
        
        stub_request(:get, "#{dominio}robots.txt").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RoboYep'}).to_return({:content_type => "text"}, :status => [200, "OK"])
        db.should_receive(:links).with(1).and_return([{"url" => dominio, "robots" => "#{dominio}robots.txt"}])
        
        TrataLink.should_receive(:trata_pagina).with(dominio, "#{dominio}robots.txt")
        
        @robo = RoboLek.start(db, db_sql, 1)
        @robo.crawl
        @robo.lista_de_links.length.should == 1
      end
    end
    
    context "#crawl" do
      it "should return page extract" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])

        db.should_receive(:links).with(1).and_return([{"url" => dominio, "robots" => "#{dominio}robots.txt"}])
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio, "#{dominio}robots.txt").and_return(trata_link) }
        
        @robo = RoboLek.start(db, db_sql, 1)
        @robo.crawl
        @robo.paginas_extraidas.length.should == 1
      end
      
      it "should return two page extract" do
        dominio = "http://www.teste.com/"
        dominio2 = "http://www.outro.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        pages << StubPage.new(dominio2, "", :links => ['teste1'])
        
        db.should_receive(:links).with(1).and_return([{"url" => dominio, "robots" => "#{dominio}robots.txt"}, {"url" => dominio2, "robots" => "#{dominio2}robots.txt"}])
        pagina.stub(links: pages[0].links_url)
        trata_link.stub(pagina: pagina)
        
        TrataLink.should_receive(:trata_pagina).with(pages[0].dominio, "#{dominio}robots.txt").and_return(trata_link)
        TrataLink.should_receive(:trata_pagina).with(pages[1].dominio, "#{dominio2}robots.txt").and_return(trata_link)
        
        @robo = RoboLek.start(db, db_sql, 1)
        @robo.crawl
        @robo.paginas_extraidas.length.should == 1
      end
    end
    
    context "#salva_links" do
      it "should call save links in db" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])
        
        pagina.stub(links: pages[0].links_url, code: "200", :url => dominio, :base_produtos => "", :robots => "#{dominio}robots.txt")
        
        db.should_receive(:links).with(1).and_return([{"url" => dominio, "robots" => "#{dominio}robots.txt"}])
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio, "#{dominio}robots.txt").and_return(pagina) }
        pages.each { |page| db.should_receive(:save_links).with(pagina.links, "#{dominio}robots.txt", dominio, "") }

        @robo = RoboLek.start(db, db_sql, 1)
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
        
        db.stub(todos_crawled?: false)

        db.should_receive(:links).with(100).and_return([{"url" => dominio, "robots" => "#{dominio}robots.txt"}])
        
        @robo = RoboLek.start(db, db_sql)
        
        pagina.stub(links: pages[0].links_url, code: "200", :url => dominio, :base_produtos => "", :robots => "#{dominio}robots.txt")
        
        TrataLink.should_receive(:trata_pagina).with(pages[0].dominio, "#{dominio}robots.txt").and_return(pagina)
        
        db.should_receive(:save_links).with(pages[0].links_url, "#{dominio}robots.txt", dominio, "")
        @robo.loop_crawl(:next)
      end
      
      it "should return and save produto" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['produto/teste2'])
        pages << StubPage.new("#{dominio}produto/teste2", "", :links => [])
        
        db.stub(todos_crawled?: false)

        db.should_receive(:links).with(100).and_return([{"url" => dominio, "produtos" => "#{dominio}produto/", "robots" => "#{dominio}robots.txt"}])
        
        @robo = RoboLek.start(db, db_sql)
        
        pagina.stub(links: [], :url => dominio, code: "200", :produtos => ["#{dominio}produto/teste2"])
        
        TrataLink.should_receive(:trata_pagina).with("#{dominio}", "#{dominio}robots.txt", "#{dominio}produto/").and_return(pagina)
        
        db.should_receive(:save_produtos).with(["#{dominio}produto/teste2"])
        @robo.loop_crawl(:next)
      end
      
    end
    
    context "#all_produtos" do
      it "should return produtos" do
        dominio = "http://www.teste.com/"
        produtos = [{"url" => "#{dominio}produtos/teste1"}]
        pages = []
        pages << StubPage.new(dominio, "", :links => ['produtos/teste1'])
        pages << StubPage.new("#{dominio}produtos/teste1", "", :links => [])
        
        db.should_receive(:links).with(100).and_return([{"url" => dominio, "produtos" => "#{dominio}produtos/", "robots" => "#{dominio}robots.txt"}])
        
        @robo = RoboLek.start(db, db_sql)
        @robo.crawl
        
        db.should_receive(:all_produtos).and_return(produtos)
        @robo.all_produtos.should == produtos
      end
    end
    
    context "#all_produtos_sql" do
      it "should return produtos from db sqlite" do
        produtos = [["www.teste.com/"]]
        db_sql.should_receive(:all_produtos_url).and_return(produtos)
        
        @robo = RoboLek.start(db, db_sql)
        
        @robo.all_produtos_sql.should == produtos
      end
    end
  end
end