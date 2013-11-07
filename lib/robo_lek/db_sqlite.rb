begin
  require "sqlite3"
rescue LoadError
end

module RoboLek
  
  def self.DBSqlite(db = nil)
    db ||= SQLite3::Database.new "db/test.sqlite3" 
    self::DBSqlite.new(db)
  end
  
  class DBSqlite
    def initialize(db)
      @db = db
    end
    
    def insert(produto, url, foto, preco, genero)
      begin
        @db.execute("insert into produtos (nome, link, foto, preco, genero, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", [produto, url, foto, preco, genero, "#{Time.now}", "#{Time.now}"])
      rescue SQLite3::ConstraintException => e
        puts "[insert] #{e}"
      end
    end
    
    def save_produtos(produto, url, foto, preco, genero)
      begin
        if foto && foto != ""
          @db.execute("insert into produtos (nome, link, foto, preco, genero, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", [produto, url, foto, preco, genero, "#{Time.now}", "#{Time.now}"])
        else
          puts "[save_produtos] error ======================================#{url}===================================================================================================================="
        end
      rescue SQLite3::ConstraintException => e
        puts "[save_produtos] #{e} -- [#{url}]"
      end
    end
    
    def all_produtos
      @db.execute("select * from produtos")
    end
    
    def all_produtos_url
      @db.execute("select link from produtos")
    end
    
    def clean
      @db.execute("Delete from produtos")
    end
  end
end