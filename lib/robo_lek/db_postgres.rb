require "pg"

module RoboLek
  def self.DBPostgres(db = nil)
     db ||= PG.connect( dbname: 'de9l8bngbisnce', user: "ofbtmqnfnrdbab", password: "txGRghwDUlHzXDY9tXs418T5lP", host: "ec2-23-21-94-137.compute-1.amazonaws.com", port: "5432")
     self::DBPostgres.new(db)
  end
  
  class DBPostgres
     def initialize(db)
       @db = db
     end

     def insert(produto, url, foto, preco, genero, tamanho)
       begin
         begin
           @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, tamanho, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7, $8)")
         rescue PG::Error => e
           @db.exec("DEALLOCATE insert_values")
           @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, tamanho, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7, $8)")
         end
         @db.exec_prepared("insert_values", [produto, url, foto, preco, genero, tamanho, "#{Time.now}", "#{Time.now}"])
       rescue PG::Error => e
         puts "[insert] #{e}"
       end
     end

     def save_produtos(produto, url, foto, preco, genero, tamanho)
       begin
         if foto && foto != ""
           begin
             @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, tamanho, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7, $8)")
           rescue PG::Error => e
             puts "[save_produtos] PG::Error #{e} -- [#{url}]"
             @db.exec("DEALLOCATE insert_values")
             @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, tamanho, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7, $8)")
           end
           @db.exec_prepared("insert_values", [produto, url, foto, preco, genero, tamanho, "#{Time.now}", "#{Time.now}"])
         else
           puts "[save_produtos] error ======================================#{url}===================================================================================================================="
         end
       rescue PG::Error => e
         puts "[save_produtos] #{e} -- [#{url}]"
       end
     end

     def all_produtos
       @db.exec("select * from produtos")
     end

     def all_produtos_url
       @db.exec("select link from produtos")
     end

     def clean
       @db.exec("Delete from produtos")
     end
  end
end