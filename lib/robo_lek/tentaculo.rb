module RoboLek
  class Tentaculo
    def initialize(links_queue, paginas_extraidas)
      @links_queue = links_queue
      @paginas_extraidas = paginas_extraidas
    end
    
    def run
      loop do
        link = @links_queue.pop
        
        puts "[run] link = #{link}"
        
        break if link == :FIM
        
        @paginas_extraidas << TrataLink.trata_pagina(link['url'])
      end
    end
  end
end