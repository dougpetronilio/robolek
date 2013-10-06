module RoboLek
  
  VERSION = '0.0.1';
  
  def RoboLek.start(db = RoboLek.DBMongo, count = 100)
    Crawler.start(db, count)
  end

  class Crawler
    attr_reader :lista_de_links, :links_extraidos
    
    def initialize(db, count)
      @db_mongo = db
      @lista_de_links = carrega_lista_de_links(count)
      @links_extraidos = extrai_links
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
    
    private
    def carrega_lista_de_links(count)
      @db_mongo.links(count) || []
    end
    
    def extrai_links
      @links_extraidos = []
      if @lista_de_links
        @lista_de_links.each do |link|
          extraidos = TrataLink.trata_pagina(link)
          extraidos.each { |l| @links_extraidos << l} if extraidos
        end
      end
      @links_extraidos
    end
  end
end