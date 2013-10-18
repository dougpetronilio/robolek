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
      @code = 200
      @code = opcoes[:code] if opcoes.has_key?(:code)
      @dominio = dominio
      
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
      @body = "<html><body>"
      @links.each { |link| @body += "<a href=\"#{@dominio}#{link}\"></a>"} if @links
      @hrefs.each { |href| @body += "<a href=\"#{link}\"></a>"} if @hrefs
      @body += "</body></html>"
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