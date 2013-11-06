module RoboLek
  class Tentaculo
    def initialize(queue, pages, tipo)
      @queue = queue
      @pages = pages
      @tipo = tipo
    end
    
    def run
      loop do
        if @tipo == :pagina
          link = @queue.pop
          produto = link['produtos']
          #puts "[run] link = #{link}"

          break if link == :FIM

          if produto
            @pages << TrataLink.trata_pagina(link['url'], link['robots'] , produto, link['base_preco'], link['base_foto'], link['base_genero'], link['base_nome'])
          else
            @pages << TrataLink.trata_pagina(link['url'], link['robots'], "", link['base_preco'], link['base_foto'], link['base_genero'], link['base_nome'])
          end
        else
          produto = @queue.pop
          #puts "[run] produto = #{produto} | "
          
          break if produto == :FIM
          
          @pages << TrataProduto.trata_produto(produto['url'], produto['base_preco'], produto['base_foto'], produto['base_genero'], produto['base_nome'])
        end
      end
    end
  end
end