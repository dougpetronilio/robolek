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
      @colecao.ensure_index(:url, :unique => true)
     
    end
    
    def links(count)
      @links = @colecao.find({}, :sort => ["date_saved", "desc"]).limit(count)
    end
    
    def insert(valor)
      begin
        @colecao.insert(valor)
      rescue
      end
    end
    
    def save(links)
      links.each do |url| 
        begin
          @colecao.insert({:url => url, :date_saved => Time.now})
        rescue Mongo::OperationFailure => e
           #STDOUT.puts "[save] -- #{e.message}"
        end
      end if links
    end
    
    def close
      @db_mongo.connection.close
    end
    
    def clean
      @colecao.remove
    end
  end
end