Dado(/^que inicio o robolek$/) do
  @robolek = RoboLek.start
end

Dado(/^que os seguintes links corretos existem no banco de dados:$/) do |table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url'], :robots => line['robots']})
    cria_mock(line['url'], ['teste1', 'teste2'], 200)
  end
end

Dado(/^que os seguintes links corretos existem no banco de dados para robo:$/) do |table|
  @lista_de_links_nas_paginas = []
  @lista_de_produtos = []
  table.hashes.each do |line|
    if line['produtos']
      if line['produto'] == "true"
        @lista_de_produtos << "#{line['url']}"
        cria_mock(line['url'], [], 200)
      else
        puts "[cadastro_de_links] produtos = #{line['produtos']} | #{line['produto']} | #{line['url']}"
        @robolek.insert({:url => line['url'], :produtos => line['produtos'], :robots => line['robots'], :base_preco => ".produto .price .new-price", :base_foto => ".produto .foto img", :base_genero => ".produto .genero a"})
        @lista_de_links_nas_paginas << "#{line['url']}"
        @lista_de_links_nas_paginas << "http://www.teste.com/homem/teste1"
        cria_mock(line['url'], ['produtos/1'], 200, :title => "teste1", :preco => "R$ 100,00", :foto => "foto1", :genero => "Masculino",)
        cria_mock("http://www.teste.com/homem/teste1", [], 200)
      end
    else
      @robolek.insert({:url => line['url'], :robots => line['robots']})
      cria_mock(line['url'], ['teste1', 'teste2'], 200)
      cria_mock("#{line['url']+"teste1"}", ["/teste3"], 200)
      cria_mock("#{line['url']+"teste2"}", ["/teste4"], 200)
      cria_mock("#{line['url']+"teste2/teste4"}", [], 200)
      cria_mock("#{line['url']+"teste1/teste3"}", [], 200)
      @lista_de_links_nas_paginas << "#{line['url']}"
      @lista_de_links_nas_paginas << "#{line['url']}teste1"
      @lista_de_links_nas_paginas << "#{line['url']}teste2"
      @lista_de_links_nas_paginas << "#{line['url']}teste1/teste3"
      @lista_de_links_nas_paginas << "#{line['url']}teste2/teste4"
    end
  end
end

Dado(/^que os seguintes links errados existem no banco de dados:$/) do |table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url'], :robots => line['robots']})
    cria_mock(line['url'], [], 400)
  end
end

Dado(/^que os seguintes links com redireciomento para "(.*?)" existem no banco de dados:$/) do |arg1, table|
  @lista_de_links_nas_paginas = []
  table.hashes.each do |line|
    @robolek.insert({:url => line['url'], :robots => line['robots']})
    cria_mock_redirecionamento(line['url'], [], 302, arg1)
    @lista_de_links_nas_paginas << line['url']
    @lista_de_links_nas_paginas << arg1
  end
end

Quando(/^pego os links do banco de dados$/) do
  @robolek.crawl
  @links = @robolek.all_links
end

Então(/^devo ter "(.*?)" na lista$/) do |arg1|
  @links.first['url'].should include(arg1)
end

Então(/^Limpa banco de dados$/) do
  @robolek.clean_db
end

Quando(/^extraio os links de cada site na lista$/) do
  @robolek.crawl
  @links_extraidos = @robolek.paginas_extraidas
end

Quando(/^salvo os links extraidos no banco de dados$/) do
  @robolek.salva_links
end

Então(/^links devem estar no banco de dados$/) do
  lista_de_links_banco_ordenada = []
  @links.each do |link|
    lista_de_links_banco_ordenada << link['url']
  end if @links
  lista_de_links_banco_ordenada = lista_de_links_banco_ordenada.sort
  lista_de_links_nas_paginas_ordenada = @lista_de_links_nas_paginas.sort
  #STDOUT.puts "#{lista_de_links_banco_ordenada} == #{lista_de_links_nas_paginas_ordenada}"
  lista_de_links_nas_paginas_ordenada.should == lista_de_links_banco_ordenada
end

Então(/^devo retornar uma pagina com erro$/) do
  @links_extraidos.each do |pagina_erro| 
    pagina_erro.code.to_i.should be_between(400, 417)
    pagina_erro.links.should == []
  end
end

Então(/^devo ser redirecionado para o site destino "(.*?)"$/) do |arg1|
  @links_extraidos.first.pagina.code.to_i.should be_between(200, 206)
  @links_extraidos.first.pagina.dominio.should == arg1
end

Quando(/^inicio o loop do robo$/) do
  cont = 0
  while(cont <= 3)
    @robolek.loop_crawl(:next)
    cont += 1
  end
  @links_extraidos = @robolek.paginas_extraidas
end

Quando(/^pego os produtos do banco de dados$/) do
  @produtos = @robolek.all_produtos
end

Então(/^produtos devem estar no banco de dados$/) do
  lista_de_produtos_banco_ordenada = []
  
  @produtos.each do |link|
    lista_de_produtos_banco_ordenada << link['url']
  end if @links
  
  lista_de_produtos_banco_ordenada = lista_de_produtos_banco_ordenada.sort
  lista_de_produtos_ordenada = @lista_de_produtos.sort
  STDOUT.puts "#{lista_de_produtos_ordenada} == #{lista_de_produtos_banco_ordenada}"
  lista_de_produtos_ordenada.should == lista_de_produtos_banco_ordenada
end

Então(/^produtos devem estar no sqlite$/) do
  @produtos_sql = @robolek.all_produtos_sql
  puts "[sql] - #{@produtos_sql.class}"
  puts "[sql] - #{@produtos_sql} / #{@lista_de_produtos}"
  @produtos_sql[0].should == @lista_de_produtos
end