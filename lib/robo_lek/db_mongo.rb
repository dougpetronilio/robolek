require "mongo"

module RoboLek
  
  def self.DBMongo(db_mongo = nil)
    db_mongo ||= Mongo::Connection.new.db('robolek')
    raise "Necessário ter o banco de dados MongoDb instalado." unless db_mongo.is_a?(Mongo::DB)
    self::DBMongo.new(db_mongo)
  end
  
  class DBMongo
    DOMINIO = 'http://www.example.com/'
    
    def initialize(db_mongo)
      @links = []
      @db_mongo = db_mongo
      @colecao = @db_mongo['paginas']
      @colecao.create_index "url"
    end
    
    def links(count)
      @links = @colecao.find().limit(count)
    end
    
    def insert(valor)
      @colecao.insert(valor)
    end
    
    def save(links)
      links.each { |url| @colecao.insert({:url => url, :date_saved => Time.now}) } if links
    end
    
    def close
      @db_mongo.connection.close
    end
    
    def clean
      @colecao.remove
    end
  end
end