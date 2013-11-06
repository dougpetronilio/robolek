require 'net/https'
require 'nokogiri'
#require 'watir'

module RoboLek
  class TrataProduto
    
    attr_reader :nome, :url, :foto, :preco, :genero, :code, :body
    
    def initialize(link, base_preco, base_foto, base_genero, base_nome)
      @url = link
      @base_preco = base_preco
      @base_foto = base_foto
      @base_genero = base_genero
      @base_nome = base_nome
      @nome = ""
      @foto = ""
      @preco = ""
      @genero = ""
      @code = ""
      extrai_links(@url)
    end
    
    def self.trata_produto(link, base_preco = "", base_foto = "", base_genero = "", base_nome = "")
      self.new(link, base_preco, base_foto, base_genero, base_nome)
    end
    
    private
    def extrai_links(link)
      pagina = {}
      response = abre_pagina(link)
      if response
        @code = response.code
      
        case @code.to_i
        when (200..206)
          @body = response.body
          @nome = pega_nome
          @preco = pega_preco
          @foto = pega_foto
          @genero = pega_genero
        when (300..307)
          #puts "#"*50
          #puts "[trata_produto][extrai_links] 1++++ @url = #{@url}"
          u = response['location']
          @url = URI.join(@url, u).to_s
          #puts "[trata_produto][extrai_links] 2---- @url = #{@url}"
          #puts "#"*50
          response = abre_pagina(@url)
          if response
            @code = response.code
            if (200..206).include?(@code.to_i)
              @body = response.body
              @nome = pega_nome
              @preco = pega_preco
              @foto = pega_foto
              @genero = pega_genero
            end
          end
        when (400..417)
          STDOUT.puts "Erro na requisição"
        when (500..505)
          STDOUT.puts "Erro no servidor"
        end
      end
    end
    
    def pega_preco
      #puts "[pega_preco] base_preco = #{@base_preco}"
      if @base_preco != ""
        @preco = doc.at_css(@base_preco).text if doc && doc.at_css(@base_preco)
        #puts "[pega_preco] preco = #{@preco}"
      else
        #puts "[pega_preco] @base_preco = nil"
        @preco = nil
      end
      @preco
    end
    
    def pega_foto
      if @base_foto && @base_foto != ""
        type = @base_foto[-3,3] if @base_foto.length > 3
        base = @base_foto[0, @base_foto.length-4] if @base_foto.length > 4
        puts "[pega_foto] type = #{type} | base = #{base}"
        if type == "rel"
          @foto = doc.at_css(base)[type] if doc && doc.at_css(base)
        else
          @foto = doc.at_css(@base_foto)["src"] if doc && doc.at_css(@base_foto)
        end
        puts "[pega_foto] html = #{doc.at_css(@base_foto)}"
        if @foto && in_domain?(@foto) == false
          @foto = "http://#{URI(@url).host}#{@foto}" if @foto.include?("//") == false && @foto != ""
        end  
        puts "[pega_foto] foto = #{@foto}"
      else
        puts "[pega_foto] @base_foto = nil"
        @foto = nil
      end
      @foto
    end
    
    def pega_genero
      if @base_genero && @base_genero != ""
        if @base_genero.downcase == "feminino"
          @genero = "Feminino"
        elsif @base_genero.downcase == "masculino"
          @genero = "Masculino"
        elsif @base_genero.downcase == "infantil"
          @genero = "Infantil"
        else
          code = doc.at_css(@base_genero).text if doc && doc.at_css(@base_genero)
          if code
            if code.downcase.include?("feminino") || code.downcase.include?("mulher") || code.downcase.include?("mulheres") || code.downcase.include?("woman")
              @genero = "Feminino"
            elsif code.downcase.include?("masculino") || code.downcase.include?("homem") || code.downcase.include?("homens") || code.downcase.include?("man")
              @genero = "Masculino"
            elsif code.downcase.include?("infantil") || code.downcase.include?("criança")
              @genero = "Infantil"
            else
              @genero = ""
            end
          else
            @genero = ""
          end
        end
        #puts "[pega_genero] genero = #{@genero}"
      else
        @genero = ''
        #puts "[pega_genero] @base_genero = ''"
        @genero = ""
      end
      @genero
    end
    
    def pega_nome
      puts "[pega_nome] nome = [#{doc.title}]"
      if @base_nome && @base_nome != ""
        nome = doc.at_css(@base_nome).text if doc && doc.at_css(@base_nome)
      else
        nome = doc.title
      end
      puts "[pega_nome] nome = #{nome}"
      nome
    end
    
    def abre_pagina(link)
      uri_encode = URI.encode(link)
      uri = URI.parse(uri_encode)
      
      #browser = Watir::Browser.new
      #browser.goto "#{link}"
      
      #puts "[abre_pagina] link = #{link}"
      retries = 0
      begin
        req = Net::HTTP::Get.new(uri)
        response = connection(uri).request(req)
      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        puts "[TrataProduto][abre_pagina] error -> #{e} ---- [#{link}]"
      rescue Exception => e
        puts "[TrataProduto][abre_pagina] error -> #{e} ---- [#{link}]"
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
      #puts "[in_domain?] url = #{@url.class} | uri = #{uri.class}"
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