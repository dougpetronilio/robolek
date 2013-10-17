#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"
require "benchmark"

robolek = RoboLek.start

robolek.insert({:url => "http://www.netshoes.com.br/"})

contador = 0
Benchmark.bm do |x|
  x.report("while") do
    while(contador <= 4)
      puts "contador = #{contador}"
      Benchmark.bm do |x|
        x.report("loop_crawl") {robolek.loop_crawl(:next)}
      end
      contador += 1
    end
  end
  
end

robolek.close_db