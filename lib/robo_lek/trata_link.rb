require 'net/https'
require 'nokogiri'

module RoboLek
  class TrataLink
    
    def initialize(link)
      @url = link
      @code = ""
      @body = ""
      @links = []
      extrai_links(link)
      @pagina = Pagina.new(link, @code, @body, @links)
    end
    
    def self.trata_pagina(link)
      self.new(link)
    end
    
    private
    def extrai_links(link)
      links = []
      pagina = {}
      request = abre_pagina(link)
      @code = request.code
      
      case @code
      when "200"
        @body = request.body
        @links = pega_links
      end
    end
    
    def abre_pagina(link)
      uri = URI(link)
      request = Net::HTTP.get_response(uri)
    end
    
    def pega_links
      links = []
      return links if !doc
      
      doc.search("//a[@href]").each do |a|
        u = a['href']
        next if u.nil? or u.empty?
        abs = URI.join( @url, u ).to_s rescue next
        links << abs if in_domain?(abs)
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