module RoboLek
  class Tentaculo
    def initialize(links_queue, pages)
      @links_queue = links_queue
      @pages = pages
    end
    
    def run
      loop do
        link = @links_queue.pop
        
        break if link == :FIM
        
        @pages << TrataLink.trata_pagina(link['url'])
      end
    end
  end
end