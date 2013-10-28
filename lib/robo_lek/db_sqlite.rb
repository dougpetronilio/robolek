require "sqlite3"

module RoboLek
  
  def self.DBSqlite(db = nil)
    db ||= SQLite3::Database.new "../estilooks/db/development.sqlite3" 
    self::DBSqlite.new(db)
  end
  
  class DBSqlite
    def initialize(db)
      @db = db
    end
    
    def insert(produto, url, foto, preco, genero)
      @db.execute("insert into produtos (produto, url, foto, preco, genero) values(?, ?, ?, ?, ?)", [produto, url, foto, preco, genero])
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