require 'net/https'
require 'nokogiri'

module RoboLek
  class TrataLink
    
    attr_reader :code, :body, :links, :pagina, :url, :base_produtos, :produtos, :robots, :base_preco, :base_foto, :base_genero, :base_nome, :base_tamanho
    
    def initialize(link, robots, base_produtos, base_preco, base_foto, base_genero, base_nome, base_tamanho)
      @url = link
      @code = ""
      @body = ""
      @links = []
      @produtos = []
      @base_produtos = base_produtos
      @base_preco = base_preco
      @base_foto = base_foto
      @base_genero = base_genero
      @base_nome = base_nome
      @base_tamanho = base_tamanho
      @robots = robots
      extrai_links(link)
      @pagina = Pagina.new(@url, @code, @body, @links, @base_produtos, @produtos)
    end
    
    def self.trata_pagina(link, robots, produtos = "", base_preco = "", base_foto = "", base_genero = "", base_nome = "", base_tamanho = "")
      self.new(link, robots, produtos, base_preco, base_foto, base_genero, base_nome, base_tamanho)
    end
    
    private
    def extrai_links(link)
      pagina = {}
      response = abre_pagina(link)
      if response
        @code = response.code
        #puts "[extrai_links] code = #{@code}"
        case @code.to_i
        when (200..206)
          @body = response.body
          @links = pega_links
        when (300..307)
          contador = 1
          while (300..307).include?(@code.to_i) && contador < 10
            #puts "[extrai_links] code = #{@code}"
            @url = response['location']
            response = abre_pagina(@url)
            if response
              @code = response.code
              if (200..206).include?(@code.to_i)
                @body = response.body
                @links = pega_links
              end
            else
              @code = "401"
            end
            contador += 1
          end
        when (400..417)
          STDOUT.puts "Erro na requisição"
        when (500..505)
          STDOUT.puts "Erro no servidor"
        end
      end
    end
    
    def abre_pagina(link)
      uri_encode = URI.encode(link)
      uri = URI.parse(uri_encode)
      #puts "[abre_pagina] link = #{link}"
      retries = 0
      begin
        req = Net::HTTP::Get.new(uri)
        response = connection(uri).request(req)
      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        puts "[abre_pagina] error -> #{e} ---- [#{link}]"
      rescue Exception => e
        puts "[abre_pagina] error -> #{e} ---- [#{link}]"
      end
      return response
    end
    
    def connection(uri)
      req = Net::HTTP.new(uri.host, uri.port)
      
      if uri.scheme == "https"
        req.use_ssl = true
        req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      
      response = req.start
    end
    
    def pega_links
      return @links if !doc
      
      doc.search("//a[@href]").each do |a|
        u = a['href']
        next if u.nil? or u.empty?
        absolute = URI.join(@url, u).to_s rescue next
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
        mat = /#{@base_produtos}/
        #puts "[link_produto?] base_produto = #{@base_produto} / mat = #{mat}"
        if mat.match(link)
          return true
        else
          return false
        end
      end
      return false
    end
    
    def doc
      Nokogiri::HTML(@body) if @body
    end
    
    def in_domain?(uri)
      if URI(uri).host && URI(@url).host
        #puts "[in_domain?] #{URI(uri).host} == #{URI(@url).host}"
        if URI(uri).host == URI(@url).host
          return true
        elsif URI(uri).host.include?(URI(@url).host)
          #puts "[in_domain?] #{uri} == #{@url}"
          return true 
        else
          return false
        end
      end
      return false
    end
  end
end