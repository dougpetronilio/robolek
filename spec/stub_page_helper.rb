require "spec_helper"

module RoboLek
  
  class StubPage
    include WebMock::API
        
    attr_accessor :links, :hrefs, :body, :nome, :dominio
    
    def initialize(dominio = "http://www.teste.com/", nome = '', opcoes = {})
      @nome = nome
      @links = [opcoes[:links]].flatten if opcoes.has_key?(:links)
      @hrefs = [opcoes[:hrefs]].flatten if opcoes.has_key?(:hrefs)
      @title = opcoes[:title] if opcoes.has_key?(:title)
      @preco = opcoes[:preco] if opcoes.has_key?(:preco)
      @foto = opcoes[:foto] if opcoes.has_key?(:foto)
      @genero = opcoes[:genero] if opcoes.has_key?(:genero)
      @body = opcoes[:body]
      @code = 200
      @code = opcoes[:code] if opcoes.has_key?(:code)
      @dominio = dominio
      @body = opcoes[:body] if opcoes.has_key?(:body)
      
      cria_body unless @body
      
      WebMock.disable_net_connect!
      if (300..307).include?(@code)
        @redirecionamento = opcoes[:redirecionamento] if opcoes.has_key?(:redirecionamento)
        cria_stub_redirecionamento
      else
        cria_stub
      end
    end
    
    def links_url
      resultado = []
      if @links
        @links.each do |link|
          resultado << "#{@dominio}#{link}"
        end
      end
      resultado << @dominio
      resultado
    end
    
    private
    def cria_body
      if @title
        @body = "<html><head><title>#{@title}</title></head><body>"
      else
        @body = "<html><body>"
      end
      @links.each { |link| @body += "<a href=\"#{@dominio}#{link}\"></a>"} if @links
      @body += "<div class='produto'>"
      @body += "<div class='teste'>"
      @body += "<form name='addToCart' action='/checkout/add-to-cart.jsp' method='GET'>"
      if @preco
        @body += "<div class='price'>"
        @body += "<strong class='new-price'>#{@preco}</strong>"
        @body += "</div>"
      end
      if @foto
        @body += "<div class='foto'>"
        @body += "<img src='/#{@foto}'>"
        @body += "</div>"
      end
      if @genero
        @body += "<div class='genero'>"
        @body += "<a href='/homem/teste1'>#{@genero}</a>"
        @body += "</div>"
      end
      @body += "</form>"
      @body += "</div>"
      @body += "</div>"
      @hrefs.each { |href| @body += "<a href=\"#{link}\"></a>"} if @hrefs
      @body += "</body></html>"
      puts "[cria_body] #{@body}"
    end
    
    def cria_stub
      options = {:body => @body, :content_type => "text/html", :status => [@code, "OK"]}
      
      stub_request(:get, "#{@dominio}robots.txt").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RoboYep'}).to_return({:body=> "User-agent: * \n Allow: */*", :content_type => "text", :status => [@code, "OK"]})
      stub_request(:get, @dominio + @nome).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(options)
    end
    
    def cria_stub_redirecionamento
      stub_request(:get, @dominio + "").to_return(:status => [@code, "Permanently Moved"], :headers => {:location => @redirecionamento})
    end
  end
end