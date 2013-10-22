require 'net/https'
require 'nokogiri'

module RoboLek
  class TrataLink
    
    attr_reader :code, :body, :links, :pagina, :url, :base_produtos, :produtos
    
    def initialize(link, robots, base_produtos)
      @url = link
      @code = ""
      @body = ""
      @links = []
      @produtos = []
      @base_produtos = base_produtos
      @robots = robots
      extrai_links(link)
      @pagina = Pagina.new(@url, @code, @body, @links, @base_produtos, @produtos)
    end
    
    def self.trata_pagina(link, robots, produtos = "")
      self.new(link, robots, produtos)
    end
    
    private
    def extrai_links(link)
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
      uri_encode = URI.encode(link)
      uri = URI.parse(uri_encode)
      puts "[abre_pagina] link = #{link}"
      response = Net::HTTP.get_response(uri)
    end
    
    def pega_links
      return @links if !doc
      
      doc.search("//a[@href]").each do |a|
        u = a['href']
        next if u.nil? or u.empty?
        absolute = URI.join( @url, u ).to_s rescue next
        if link_produto?(absolute)
          @produtos << absolute if in_domain?(absolute)
        else
          @links << absolute if in_domain?(absolute)
        end
      end
      
      @links << @url
      
      @links.uniq!
      @links
    end
    
    def link_produto?(link)
      #puts "[link_produto?] #{link.class} | #{@base_produtos} | #{link}"
      if @base_produtos != nil && @base_produtos != ""
        return link.include?(@base_produtos)
      end
      return false
    end
    
    def doc
      Nokogiri::HTML(@body) if @body
    end
    
    def in_domain?(uri)
      URI(uri).host == URI(@url).host
    end
  end
end