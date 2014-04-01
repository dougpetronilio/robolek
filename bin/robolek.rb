#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"
require "benchmark"

robolek = RoboLek.start(db = RoboLek.DBMongo(nil, "robolek", "mongodb://heroku:robo2013lek@paulo.mongohq.com:10076/app19255853"), db_sql = RoboLek.DBPostgres)
#robolek = RoboLek.start

robolek.clean_db

#robolek.insert({:url => "http://www.stoza.com.br/", :produtos => "(http://www.stoza.com.br/camiseta/)(.+)", :robots => "http://www.stoza.com.br/robots.txt", :base_preco => ".container .content .summary .price .amount", :base_foto => ".container .row-fluid .span6 .flexslider_galeria .slides img", :base_genero => "", :base_nome => ""})
robolek.insert({:url => "http://www.farfetch.com.br/", :produtos => "(http://www.farfetch.com.br/shopping/)(.+)(storeid=)(.+)", :robots => "http://www.farfetch.com.br/robots.txt", :base_preco => ".content .container #productDescriptionWrapper #productItemDesc #ContentPlaceBody_TemplateBody_lbPrice", :base_foto => ".content .container #productZoomWrapper #productZoomImg #productZoomImgCarousel .productZoomImgCarousel-IMG img", :base_genero => ".content .container .contentBreadcrumbs", :base_nome => ".content .container #productDescriptionWrapper #productItemDesc .productFriendly", :base_tamanho => ""})
robolek.insert({:url => "http://store.ellus.com/", :produtos => "(http://store.ellus.com/product/)(.+)", :robots => "http://store.ellus.com/robots.txt", :base_preco => ".provador .itemWrapper .prodTxtWrapper .buyArea #prodform .prodBuyArea .precoFinal", :base_foto => ".provador .itemWrapper .itemImg .mainPic img", :base_genero => "#content #nav #navRoot", :base_nome => ".provador .itemWrapper .prodTxtWrapper .itemNome", :base_tamanho => ""})
robolek.insert({:url => "http://e-store.animale.com.br/", :produtos => "(http://e-store.animale.com.br/loja/produto)(.+)(prod_id=)(.+)", :base_preco => ".block .box .prod_infos #frmProduto .the_price", :base_foto => ".block .box .prod_photos img rel", :base_genero => "feminino", :base_nome => ".block .box .prod_infos #frmProduto .categoria-produto .produto-nome", :base_tamanho => ""})
robolek.insert({:url => "http://www.farmrio.com.br/loja/vitrine", :produtos => "(http://www.farmrio.com.br/loja/)(.+)(produto/)(.+)(idestampafiltro=)(.+)", :robots => "http://www.farmrio.com.br/robots.txt", :base_preco => "#wrapp #content #product-details #product-data .aba_Description #price .price-product", :base_foto => "#wrapp #content #product-details #product-images #image-big img", :base_genero => "feminino", :base_nome => "#wrapp #content #product-details #product-data .wrapper-title h1", :base_tamanho => ""})
robolek.insert({:url => "http://www.gallerist.com.br/", :produtos => "(http://www.gallerist.com.br/prod/)(.+)(aspx)", :robots => "http://www.gallerist.com.br/robots.txt", :base_preco => "#main .container .content #info-product .details #lblPrecoPor", :base_foto => "#main .container .content #info-product .images .photo img", :base_genero => "feminino", :base_nome => "#main .container .content #info-product .details .name", :base_tamanho => ""})
#robolek.insert({:url => "http://www.netshoes.com.br/", :produtos => "(http://www.netshoes.com.br/produto/)(.+)", :robots => "http://www.netshoes.com.br/robots.txt", :base_preco => ".body-holder .product-buy-component .product-buy-wrapper .base-box .product-info-holder .price-holder .new-price-holder .new-price", :base_foto => ".body-holder .product-buy-component .product-photo-wrapper .photo-gallery-wrapper .product-img .aligner img", :base_genero => ".body-holder #features-box #caracteristicas .description-list", :base_nome => ".body-holder .product-buy-component .product-name-holder .base-title"})

#foto       ----> robolek.insert({:url => "http://www.glamour.com.br/", :produtos => "(http://www.glamour.com.br/)(.+)(/p)", :robots => "http://www.glamour.com.br/robots.txt", :base_preco => ".PG-Global .PG-Produto-Conteudo .PG-Produto-Informacoes .descricao-preco .valor-por", :base_foto => ".PG-Global .PG-Produto-Conteudo .PG-Produto-Informacoes .PG-Produto-Conteudo-Visualizacao #show "})
#javascript ----> robolek.insert({:url => "http://www.dafiti.com.br/", :produtos => "(http://www.dafiti.com.br/)(.+)(\.html)", :robots => "http://www.dafiti.com.br/robots.txt", :base_preco => ".l-full-content .l-product-sale-information .box-information", :base_foto => ".full-content .l-full-content .l-product-container .product-img-box .product-img-box-image img", :base_genero => ""})

contador = 0
Benchmark.bm do |x|
  x.report("while") do
    while(contador < 1)
      puts "contador = #{contador}"
      Benchmark.bm do |x|
        x.report("loop_crawl") {robolek.loop_crawl(:next)}
      end
      contador += 1
    end
  end
  
end

robolek.close_db