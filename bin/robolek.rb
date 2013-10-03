#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"

robolek = RoboLek.start

robolek.insert({:url => "www.seila.com"})

puts robolek.lista_de_links