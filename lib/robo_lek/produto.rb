
module RoboLek
  class Produto
    attr_reader :dominio, :code, :body
    
    def initialize(dominio = '', code, body)
      @dominio = dominio
      @code = code
      @body = body
    end
  end
end