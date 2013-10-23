#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"
require "benchmark"

robolek = RoboLek.start

robolek.insert({:url => "http://www.netshoes.com.br/", :produtos => "(http://www.netshoes.com.br/produto/)(.+)", :robots => "http://www.netshoes.com.br/robots.txt"})
#robolek.insert({:url => "http://www.stoza.com.br/", :produtos => "(http://www.stoza.com.br/camiseta/)(.+)", :robots => "http://www.stoza.com.br/robots.txt"})
#robolek.insert({:url => "http://www.farfetch.com.br/", :produtos => "(http://www.farfetch.com.br/shopping/)(.+)(storeid=)(.+)", :robots => "http://www.farfetch.com.br/robots.txt"})

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