require "thread"
require "robotex"
require "benchmark"

module RoboLek
  
  VERSION = '0.0.1';
  
  def RoboLek.start(db = RoboLek.DBMongo, db_sql = RoboLek.DBSqlite, count = 100, threads = 40)
    Crawler.start(db, db_sql, count, threads)
  end

  class Crawler
    attr_reader :lista_de_links, :paginas_extraidas
    
    def initialize(db, db_sql, count, threads_count)
      @db_sql = db_sql
      @db_mongo = db
      @count = count
      @threads = []
      @threads_count = threads_count
      @lista_de_links = []
      @queue_links = Queue.new
      @paginas_extraidas = []
      @produtos_extraidos = []
      @robotex = Robotex.new("RoboYep")
    end
    
    def fim?
      @db_mongo.todos_crawled?
    end
    
    def self.start(db, db_sql, count, threads)
      self.new(db, db_sql, count, threads)
    end
    
    def insert(valor)
      @db_mongo.insert(valor)
    end
    
    def clean_db
      @db_mongo.clean
      @db_sql.clean
    end
    
    def crawl
      carrega_lista_de_links(@count)
      @paginas_extraidas = extrai_paginas
      carrega_produtos
      @produtos_extraidos = extrai_produtos
    end
    
    def salva_links
      @paginas_extraidas.each do |pagina|
        @db_mongo.save_links(pagina.links, pagina.robots, pagina.url, pagina.base_produtos, pagina.base_preco, pagina.base_foto, pagina.base_genero) if pagina.code == "200"
        @db_mongo.save_produtos(pagina.produtos, pagina.base_preco, pagina.base_foto, pagina.base_genero) if pagina.code == "200"
      end if @paginas_extraidas
    end
    
    def salva_produtos
      #puts "[salva_produtos] #{@produtos_extraidos}"
      @produtos_extraidos.each do |produto|
        @db_sql.save_produtos(produto.nome, produto.url, produto.foto, produto.preco, produto.genero) if produto
      end if @produtos_extraidos
    end
    
    def loop_crawl(sinal = :next)
      if fim?
        close_db
      else
        if sinal == :next
          puts ""
          puts "#"*70
          Benchmark.bm do |x|
            x.report("crawl") { crawl }
          end
          Benchmark.bm do |x|
            x.report("salva_links") { salva_links }
          end
          Benchmark.bm do |x|
            x.report("salva_produtos") { salva_produtos }
          end
          @paginas_extraidas = []
          @produtos_extraidos = []
          puts ""
          puts "#"*70
        end
      end
    end
    
    def close_db
      @db_mongo.close
    end
    
    def all_links
      @db_mongo.all_links(@count).to_a
    end
    
    def all_produtos
      @db_mongo.all_produtos.to_a
    end
    
    def all_produtos_sql
      @db_sql.all_produtos_url
    end
    
    private
    def carrega_lista_de_links(count)
      @lista_de_links = []
      @queue_links = Queue.new
      
      links = @db_mongo.links(count)
      links.each do |link| 
        if link_liberado?(link['robots'])
          @lista_de_links << link
          @queue_links << link
        end
      end if links
    end
    
    def carrega_produtos
      @queue_produtos = Queue.new
      
      links = @db_mongo.all_produtos.to_a
      
      links.each do |link|
        @queue_produtos << link
      end if links
    end
    
    def link_liberado?(link)
      ret = true
      #puts "[link_liberado?] link = #{link}"
      if link && link != ""
        #puts "[link_liberado?] if ----------------- link = #{link}"
        uri_encode = URI.encode(link)
        uri = URI.parse(uri_encode)
        ret = @robotex.allowed?(uri)
      end
      return ret
    end
    
    def extrai_paginas
      @threads = []

      @threads_count.times do
        @threads << Thread.new {Tentaculo.new(@queue_links, @paginas_extraidas, :pagina).run}
      end
      
      loop do
        if @queue_links.empty?
          @threads.size.times {@queue_links << :FIM}
          break
        end
      end

      @threads.each {|thread| thread.join}
      
      @paginas_extraidas.uniq!
      @paginas_extraidas
    end
    
    def extrai_produtos
      @threads = []

      @threads_count.times do
        @threads << Thread.new {Tentaculo.new(@queue_produtos, @produtos_extraidos, :produto).run}
      end
      
      loop do
        if @queue_produtos.empty?
          @threads.size.times {@queue_produtos << :FIM}
          break
        end
      end

      @threads.each {|thread| thread.join}
      
      @produtos_extraidos.uniq!
      @produtos_extraidos
    end
  end
end