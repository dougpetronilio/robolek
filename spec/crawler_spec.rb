require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe Crawler do
    let(:db) { double("db").as_null_object }
    context "#start" do      
      it "should have links in list when start robolek" do
        dominio = "http://www.teste.com/"
        db.should_receive(:links).with(1).and_return([dominio])
        TrataLink.should_receive(:trata_pagina).with(dominio)
        
        RoboLek.start(db, 1).lista_de_links.length.should == 1
      end
    end
    
    context "#crawl" do
      it "should extract links in url" do
        dominio = "http://www.teste.com/"
        pages = []
        pages << StubPage.new(dominio, "", :links => ['teste1', 'teste2'])

        db.should_receive(:links).with(1).and_return([dominio])
        
        pages.each { |page| TrataLink.should_receive(:trata_pagina).with(dominio).and_return(page.links_url) }
        
        RoboLek.start(db, 1).links_extraidos.length.should == 2
      end
    end
  end
end