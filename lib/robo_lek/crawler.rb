module RoboLek
  
  VERSION = '0.0.1';
  
  def RoboLek.start(db = RoboLek.DBMongo, count = 100)
    Crawler.start(db, count)
  end

  class Crawler
    attr_reader :lista_de_links
    
    def initialize(db, count)
      @db_mongo = db
      @lista_de_links = carrega_lista_de_links(count)
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
  end
end