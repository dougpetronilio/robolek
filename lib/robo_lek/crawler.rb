require "thread"
require "robotex"
require "benchmark"

module RoboLek
  
  VERSION = '0.0.1';
  
  def RoboLek.start(db = RoboLek.DBMongo, count = 100, threads = 10)
    Crawler.start(db, count, threads)
  end

  class Crawler
    attr_reader :lista_de_links, :paginas_extraidas
    
    def initialize(db, count, threads_count)
      @db_mongo = db
      @count = count
      @threads = []
      @threads_count = threads_count
      @lista_de_links = []
      @queue_links = Queue.new
      @paginas_extraidas = []
      @robotex = Robotex.new("RoboYep")
    end
    
    def fim?
      @db_mongo.todos_crawled?
    end
    
    def self.start(db, count, threads)
      self.new(db, count, threads)
    end
    
    def insert(valor)
      @db_mongo.insert(valor)
    end
    
    def clean_db
      @db_mongo.clean
    end
    
    def crawl
      carrega_lista_de_links(@count)
      @paginas_extraidas = extrai_paginas
    end
    
    def salva_links
      @paginas_extraidas.each do |pagina|
        @db_mongo.save_links(pagina.links, pagina.url, pagina.base_produtos) if pagina.code == "200"
        @db_mongo.save_produtos(pagina.produtos) if pagina.code == "200"
      end if @paginas_extraidas
    end
    
    def loop_crawl(sinal = :next)
      if sinal == :next
        puts ""
        puts "#"*70
        Benchmark.bm do |x|
          x.report("crawl") { crawl }
        end
        Benchmark.bm do |x|
          x.report("salva_links") { salva_links }
        end
        @paginas_extraidas = []
        puts ""
        puts "#"*70
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
      end
    end
    
    def link_liberado?(link)
      ret = false
      if link && link != ""
        puts "[link_liberado?] link = #{link}"
        uri_encode = URI.encode(link)
        uri = URI.parse(uri_encode)
        ret = @robotex.allowed?(uri)
      else
        ret = true
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
  end
end