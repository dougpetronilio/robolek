module RoboLek
  class Tentaculo
    def initialize(queue, pages, tipo)
      @queue = queue
      @pages = pages
      @tipo = tipo
    end
    
    def run
      loop do
        link = @queue.pop
        produto = link['produtos']
        #puts "[run] link = #{link}"
        
        break if link == :FIM
        
        if produto
          @pages << TrataLink.trata_pagina(link['url'], link['robots'] , produto)
        else
          @pages << TrataLink.trata_pagina(link['url'], link['robots'])
        end
      end
    end
  end
end