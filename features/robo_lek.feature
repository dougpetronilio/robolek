
# language: pt

Funcionalidade: robolek trata links
	Inicio o robo lendo os links do banco de dados, adiciono os links 
	lidos do banco de dados em uma lista, pego cada links e mando pro
	trata_link, recebo o retorno e salvo os links no banco de dados
	
	
	Cenário: Inicio o robolek leio os links do banco de dados
		Dado que inicio o robolek
		E que os seguintes links corretos existem no banco de dados:
		| url					| date       | robots                          |
		| http://www.teste.com/ | 2013-10-03 | http://www.teste.com/robots.txt |
		Quando pego os links do banco de dados
		Então devo ter "http://www.teste.com/" na lista
		E Limpa banco de dados
	
	Cenário: Crawl os links carregados do banco de dados são tratados e é extraído os links das paginas
		Dado que inicio o robolek
		E que os seguintes links corretos existem no banco de dados para robo:
		| url				    | date       | robots                          |
		| http://www.teste.com/ | 2013-10-03 | http://www.teste.com/robots.txt |
		Quando inicio o loop do robo
		E pego os links do banco de dados
		Então links devem estar no banco de dados
		E Limpa banco de dados

		
	Cenário: Crawl link que não existe
		Dado que inicio o robolek
		E que os seguintes links errados existem no banco de dados:
		| url				    | date       | robots                          |
		| http://www.teste.com/ | 2013-10-03 | http://www.teste.com/robots.txt |
		Quando extraio os links de cada site na lista
		Então devo retornar uma pagina com erro
		E Limpa banco de dados
		
	Cenário: Crawl link com redirecionamento
		Dado que inicio o robolek
		E que os seguintes links com redireciomento para "http://www.teste.com/teste" existem no banco de dados:
		| url                   | date       | robots                          |
		| http://www.teste.com/ | 2013-10-03 | http://www.teste.com/robots.txt |
		Quando extraio os links de cada site na lista
		Então devo ser redirecionado para o site destino "http://www.teste.com/teste"
		E salvo os links extraidos no banco de dados
		Quando pego os links do banco de dados
		Então links devem estar no banco de dados
		E Limpa banco de dados


	Cenário: Crawl link com produtos
		Dado que inicio o robolek
		E que os seguintes links corretos existem no banco de dados para robo:
		| url				              | date       | produtos                      | produto | robots                          |
		| http://www.teste.com/           | 2013-10-03 | http://www.teste.com/produtos | false   | http://www.teste.com/robots.txt |
		| http://www.teste.com/produtos/1 | 2013-10-03 | http://www.teste.com/produtos | true    | http://www.teste.com/robots.txt |
		Quando inicio o loop do robo		
		E pego os links do banco de dados
		E pego os produtos do banco de dados
		Então links devem estar no banco de dados
		E produtos devem estar no banco de dados
		E Limpa banco de dados