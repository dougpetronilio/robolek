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
      #@colecao.ensure_index(:url, :unique => true)
    end
    
    def links(count)
      @links = @colecao.find({:crawled => false}, :sort => ["date_saved", "asc"]).limit(count)
    end
    
    def all_links(count)
      @colecao.find({}, :sort => ["date_saved", "asc"]).limit(count)
    end
    
    def insert(valor)
      begin
        @colecao.insert({:url => valor[:url], :crawled => false})
      rescue Mongo::OperationFailure => e
      end
    end
    
    def todos_crawled?
      urls = @colecao.find({:crawled => false}).to_a
      urls.count == 0
    end
    
    def save_out(links, crawled = '')
      links.each do |url| 
        begin
          @colecao.insert({:url => url, :date_saved => Time.now, :crawled => false})
        rescue Mongo::OperationFailure => e
           #puts "[save] error #{e}"
           if crawled == url
             @colecao.update({:url => url}, {"$set" => {:date_saved => Time.now, :crawled => true}})
           else
             @colecao.update({:url => url}, {"$set" => {:date_saved => Time.now}})
           end
        end
      end if links
    end
    
    def save(links, crawled = '')
      links.each do |url| 
        begin
          if crawled == url
            @colecao.update({:url => url}, {"$set" => {:date_saved => Time.now, :crawled => true}})
          else
            endereco = @colecao.find_one({:url => url})
            if endereco && endereco['url']
              @colecao.update({:url => url}, {"$set" => {:date_saved => Time.now}})
            else
              @colecao.insert({:url => url, :date_saved => Time.now, :crawled => false})
            end
          end
        rescue Mongo::OperationFailure => e
           puts "[save] error #{e}"
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