
# language: pt

Funcionalidade: robolek trata links
	Inicio o robo lendo os links do banco de dados, adiciono os links 
	lidos do banco de dados em uma lista, pego cada links e mando pro
	trata_link, recebo o retorno e salvo os links no banco de dados
	
	
	Cenário: Inicio o robolek leio os links do banco de dados
		Dado que inicio o robolek
		E que os seguintes links corretos existem no banco de dados:
		| url					| date       |
		| http://www.teste.com/ | 2013-10-03 |
		Quando pego os links do banco de dados
		Então devo ter "http://www.teste.com/" na lista
		E Limpa banco de dados
		
	Cenário: Crawl os links carregados do banco de dados são tratados e é extraído os links das paginas
		Dado que inicio o robolek
		E que os seguintes links corretos existem no banco de dados:
		| url				    | date       |
		| http://www.teste.com/ | 2013-10-03 |
		Quando extraio os links de cada site na lista
		E salvo os links extraidos no banco de dados
		Então links devem estar no banco de dados
		E Limpa banco de dados
		
	Cenário: Crawl link que não existe
		Dado que inicio o robolek
		E que os seguintes links errados existem no banco de dados:
		| url				    | date       |
		| http://www.teste.com/ | 2013-10-03 |
		Quando extraio os links de cada site na lista
		Então devo retornar uma pagina com erro
		E Limpa banco de dados
		
		
		
	