require "pg"

module RoboLek
  def self.DBPostgres(db = nil)
     db ||= PG.connect( dbname: 'd371m3gpvf3lid', user: "tjqnwfwskxddun", password: "3EGnagC_kYTOAmGlqTfnMtSnOH", host: "ec2-54-225-255-208.compute-1.amazonaws.com", port: "5432")
     self::DBPostgres.new(db)
  end
  
  class DBPostgres
     def initialize(db)
       @db = db
     end

     def insert(produto, url, foto, preco, genero)
       begin
         @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7)")
         @db.exec_prepared("insert_values", [produto, url, foto, preco, genero, "#{Time.now}", "#{Time.now}"])
         conn.exec("DEALLOCATE insert_values")
       rescue PG::Error => e
         puts "[insert] #{e}"
       end
     end

     def save_produtos(produto, url, foto, preco, genero)
       begin
         if foto && foto != ""
           @db.prepare("insert_values", "insert into produtos (nome, link, foto, preco, genero, created_at, updated_at) values($1, $2, $3, $4, $5, $6, $7)")
           @db.exec_prepared("insert_values", [produto, url, foto, preco, genero, "#{Time.now}", "#{Time.now}"])
           @db.exec("DEALLOCATE insert_values")
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