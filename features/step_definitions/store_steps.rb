Dado(/^que inicio o robolek$/) do
  @robolek = RoboLek.start
end

Dado(/^que os seguintes links existem no banco de dados:$/) do |table|
  table.hashes.each do |line|
    @robolek.insert({:url => line['url']})
    cria_mock(line['url'], ['teste1', 'teste2'])
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

Então(/^extraio os links de cada site na lista$/) do
  @robolek.crawl
  @links_extraidos = @robolek.paginas_extraidas
end

Então(/^salvo os links extraidos no banco de dados$/) do
  @robolek.salva_links
end

Então(/^links devem estar no banco de dados$/) do
  links_banco = @robolek.lista_de_links
  links_banco.each { |link| link.should include(@links_extraidos.first.links) }
end