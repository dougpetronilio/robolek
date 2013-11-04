require "spec_helper"
$:.unshift(File.dirname(__FILE__))

module RoboLek
  describe TrataProduto do
    before(:each) do
      @page = StubPage.new(DOMINIO, "", opcoes = {:title => "teste1", :preco => "R$ 100,00", :foto => "foto1", :genero => "Masculino", :links => []})
      @page_error = StubPage.new(DOMINIO_ERROR, "", opcoes = {:code => 400})
      @page_redirect = StubPage.new(DOMINIO_REDIRECIONAMENTO, "", opcoes = {:code => 301, :redirecionamento => DOMINIO})
    end
    
    context "#new" do
      it "should complete produto with body, code, nome, preco, foto and genero" do
        trata_produto = TrataProduto.trata_produto(DOMINIO, ".produto .price .new-price", ".produto .foto img", ".produto .genero a")
        trata_produto.code.should == "200"
        trata_produto.body.should == @page.body
        trata_produto.nome.should == "teste1"
        trata_produto.url.should == "#{DOMINIO}"
        trata_produto.preco.should == "R$ 100,00"
        trata_produto.foto.should == "foto1"
        trata_produto.genero.should == "Masculino"
      end
      
      it "should not complete produto" do
        trata_produto = TrataProduto.trata_produto(DOMINIO, "", "", "")
        trata_produto.code.should == "200"
        trata_produto.body.should == @page.body
        trata_produto.preco.should == nil
        trata_produto.foto.should == nil
        trata_produto.genero.should == nil
      end
    end
  end
end