require 'net/https'
require 'nokogiri'

module RoboLek
  class TrataLink
    
    attr_reader :code, :body, :links, :pagina
    
    def initialize(link)
      @url = link
      @code = ""
      @body = ""
      @links = []
      extrai_links(link)
      @pagina = Pagina.new(@url, @code, @body, @links)
    end
    
    def self.trata_pagina(link)
      self.new(link)
    end
    
    private
    def extrai_links(link)
      links = []
      pagina = {}
      response = abre_pagina(link)
      @code = response.code
      
      case @code.to_i
      when (200..206)
        @body = response.body
        @links = pega_links
      when (300..307)
        @url = response['location']
        response = abre_pagina(@url)
        @code = response.code
        if (200..206).include?(@code.to_i)
          @body = response.body
          @links = pega_links
        end
      when (400..417)
        STDOUT.puts "Erro na requisição"
      when (500..505)
        STDOUT.puts "Erro no servidor"
      end
    end
    
    def abre_pagina(link)
      uri = URI(link)
      response = Net::HTTP.get_response(uri)
    end
    
    def pega_links
      links = []
      return links if !doc
      
      doc.search("//a[@href]").each do |a|
        u = a['href']
        next if u.nil? or u.empty?
        absolute = URI.join( @url, u ).to_s rescue next
        links << absolute if in_domain?(absolute)
      end
      links.uniq!
      links
    end
    
    def doc
      Nokogiri::HTML(@body) if @body
    end
    
    def in_domain?(uri)
      URI(uri).host == URI(@url).host
    end
  end
end