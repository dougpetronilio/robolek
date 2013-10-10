Dado(/^que inicio o robolek$/) do
  @robolek = RoboLek.start
end

Dado(/^que os seguintes links corretos existem no banco de dados:$/) do |table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url']})
    cria_mock(line['url'], ['teste1', 'teste2'], 200)
  end
end

Dado(/^que os seguintes links errados existem no banco de dados:$/) do |table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url']})
    cria_mock(line['url'], [], 400)
  end
end

Dado(/^que os seguintes links com redireciomento para "(.*?)" existem no banco de dados:$/) do |arg1, table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url']})
    cria_mock_redirecionamento(line['url'], [], 302, arg1)
  end
end

Quando(/^pego os links do banco de dados$/) do
  @links = @robolek.lista_de_links
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
  links_banco = @robolek.lista_de_links
  links_banco.each { |link| link.should include(@links_extraidos.first.links) }
end

Então(/^devo retornar uma pagina com erro$/) do
  @links_extraidos.each do |pagina_erro| 
    pagina_erro.code.to_i.should be_between(400, 417)
    pagina_erro.links.should == []
  end
end

Então(/^devo ser redirecionado para o site destino "(.*?)"$/) do |arg1|
  @links_extraidos.first.pagina.code.to_i.should be_between(200, 306)
  @links_extraidos.first.pagina.dominio.should == arg1
end