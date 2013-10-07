require "spec_helper"

module RoboLek
  
  class StubPage
    include WebMock::API
        
    attr_accessor :links, :hrefs, :body, :nome, :dominio
    
    def initialize(dominio = "http://www.teste.com/", nome = '', opcoes = {})
      @nome = nome
      @links = [opcoes[:links]].flatten if opcoes.has_key?(:links)
      @hrefs = [opcoes[:hrefs]].flatten if opcoes.has_key?(:hrefs)
      @body = opcoes[:body]
      @dominio = dominio
      
      cria_body unless @body
      cria_stub
    end
    
    def links_url
      resultado = []
      if @links
        @links.each do |link|
          resultado << "#{@dominio}#{link}"
        end
      end
      resultado
    end
    
    private
    def cria_body
      @body = "<html><body>"
      @links.each { |link| @body += "<a href=\"#{@dominio}#{link}\"></a>"} if @links
      @hrefs.each { |href| @body += "<a href=\"#{link}\"></a>"} if @hrefs
      @body += "</body></html>"
    end
    
    def cria_stub
      options = {:body => @body, :content_type => "text/html", :status => [200, "OK"]}
      
      stub_request(:get, @dominio + @nome).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'www.teste.com', 'User-Agent'=>'Ruby'}).to_return(options)
    end
  end
end