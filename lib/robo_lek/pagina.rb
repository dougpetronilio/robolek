
module RoboLek
  class Pagina
    attr_reader :dominio, :code, :body, :links, :produtos, :base_produtos
    
    def initialize(dominio = '', code, body, links, base_produtos, produtos)
      @dominio = dominio
      @code = code
      @body = body
      @links = links
      @base_produtos = base_produtos
      @produtos = produtos
    end
  end
end