module RoboLek
  
  VERSION = '0.0.1';
  
  def RoboLek.start(db = RoboLek.DBMongo, count = 100)
    Crawler.start(db, count)
  end

  class Crawler
    attr_reader :lista_de_links, :paginas_extraidas
    
    def initialize(db, count)
      @db_mongo = db
      @count = count
      @lista_de_links = carrega_lista_de_links(@count)
      @paginas_extraidas = []
      
    end
    
    def self.start(db, count)
      self.new(db, count)
    end
    
    def insert(valor)
      @db_mongo.insert(valor)
    end
    
    def clean_db
      @db_mongo.clean
    end
    
    def crawl
      @paginas_extraidas = extrai_paginas
    end
    
    def salva_links
      @paginas_extraidas.each do |pagina|
        @db_mongo.save(pagina.links) if pagina.code == "200"
      end
      @lista_de_links = carrega_lista_de_links(@count)
    end
    
    def loop_crawl(sinal = :next)
      if sinal == :next
        crawl
        salva_links
        @paginas_extraidas = []
      end
    end
    
    private
    def carrega_lista_de_links(count)
      @db_mongo.links(count) || []
    end
    
    def extrai_paginas
      if @lista_de_links
        @lista_de_links.each do |link|
          @paginas_extraidas << TrataLink.trata_pagina(link['url'])
        end
      end
      @paginas_extraidas.uniq!
      @paginas_extraidas
    end
  end
end