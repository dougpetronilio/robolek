#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"
require "benchmark"

robolek = RoboLek.start

robolek.insert({:url => "http://www.netshoes.com.br/", :produtos => "http://www.netshoes.com.br/produto/"})
#robolek.insert({:url => "http://www.stoza.com.br/", :produtos => "http://www.stoza.com.br/camiseta/"})

contador = 0
Benchmark.bm do |x|
  x.report("while") do
    while(robolek.fim? == false)
      puts "contador = #{contador}"
      Benchmark.bm do |x|
        x.report("loop_crawl") {robolek.loop_crawl(:next)}
      end
      contador += 1
    end
  end
  
end

robolek.close_db