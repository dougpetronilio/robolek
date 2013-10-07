
module RoboLek
  class Pagina
    attr_reader :dominio, :code, :body, :links
    
    def initialize(dominio = '', code, body, links)
      @dominio = dominio
      @code = code
      @body = body
      @links = links
    end
  end
end