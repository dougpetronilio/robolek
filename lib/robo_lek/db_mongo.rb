require "mongo"

module RoboLek
  
  def self.DBMongo(db_mongo = nil, nome = nil)
    db_mongo ||= Mongo::Connection.new.db('robolek') if nome == nil
    db_mongo ||= Mongo::Connection.new.db('nome') if nome
    raise "Necessário ter o banco de dados MongoDb instalado." unless db_mongo.is_a?(Mongo::DB)
    self::DBMongo.new(db_mongo)
  end
  
  class DBMongo
    DOMINIO = 'http://www.example.com/'
    
    def initialize(db_mongo)
      @links = []
      @produtos
      @db_mongo = db_mongo
      @colecao_links = @db_mongo['paginas']
      @colecao_produtos = @db_mongo['produtos']
      @colecao_produtos.ensure_index(:url, :unique => true)
    end
    
    def links(count)
      @links = @colecao_links.find({:crawled => false}, :sort => ["date_saved", "asc"]).limit(count)
    end
    
    def produtos(count)
      @protudos = @colecao_produtos.find({}, :sort => ["date_saved", "asc"]).limit(count)
    end
    
    def all_produtos
      @protudos = @colecao_produtos.find({}, :sort => ["date_saved", "asc"])
    end
    
    def all_links(count)
      @colecao_links.find({}, :sort => ["date_saved", "asc"]).limit(count)
    end
    
    def insert(valor)
      begin
        produtos = ""
        robots = ""
        produtos = valor[:produtos] if valor[:produtos]
        robots = valor[:robots] if valor[:robots]
        base_preco = valor[:base_preco] if valor[:base_preco]
        base_foto = valor[:base_foto] if valor[:base_foto]
        base_genero = valor[:base_genero] if valor[:base_genero]
        base_nome = valor[:base_nome] if valor[:base_nome]
        
        @colecao_links.insert({:url => valor[:url], :crawled => false, :produtos => produtos, :robots => robots, :base_preco => base_preco, :base_genero => base_genero, :base_foto => base_foto, :base_nome => base_nome})
      rescue Mongo::OperationFailure => e
      end
    end
    
    def todos_crawled?
      urls = @colecao_links.find({:crawled => false}).to_a
      urls.count == 0
    end
    
    def save_links(links, robots, crawled = '', produtos = "", base_preco = "", base_foto = "", base_genero = "", base_nome = "")
      links.each do |url| 
        begin
          endereco = @colecao_links.find_one({:url => url})
          if endereco && endereco['url']
            if crawled == url
              @colecao_links.update({:url => url}, {"$set" => {:date_saved => Time.now, :crawled => true}})
            else
              @colecao_links.update({:url => url}, {"$set" => {:date_saved => Time.now}})
            end
          else
            @colecao_links.insert({:url => url, :date_saved => Time.now, :crawled => false, :produtos => produtos, :robots => robots, :base_preco => base_preco, :base_genero => base_genero, :base_foto => base_foto, :base_nome => base_nome})
          end
        rescue Mongo::OperationFailure => e
           puts "[save_links] error #{e}"
        end
      end if links
    end
    
    def save_produtos(links, base_preco, base_foto, base_genero, base_nome)
      links.each do |url|
        begin
          @colecao_produtos.insert({:url => url, :date_saved => Time.now, :base_preco => base_preco, :base_genero => base_genero, :base_foto => base_foto, :base_nome => base_nome})
        rescue Mongo::OperationFailure => e
          #puts "[save_links] error #{e}"
          @colecao_produtos.update({:url => url}, {"$set" => {:date_saved => Time.now}})
        end
      end
    end
    
    def close
      @db_mongo.connection.close
    end
    
    def clean
      @colecao_links.remove
      @colecao_produtos.remove
    end
  end
end