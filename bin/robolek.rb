#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"

robolek = RoboLek.start

robolek.insert({:url => "http://www.netshoes.com.br/"})

robolek.crawl
robolek.salva_links
contador = 0
robolek.paginas_extraidas.each do |pagina| 
  puts pagina.links
end

puts robolek.paginas_extraidas[0].links.length