#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib") 

require "robo_lek"
require "benchmark"

robolek = RoboLek.start

robolek.insert({:url => "http://www.netshoes.com.br/", :produtos => "(http://www.netshoes.com.br/produto/)(.+)", :robots => "http://www.netshoes.com.br/robots.txt", :base_preco => ".body-holder .product-buy-component .product-buy-wrapper .base-box .product-info-holder .price-holder .new-price-holder .new-price", :base_foto => ".body-holder .product-buy-component .product-photo-wrapper .photo-gallery-wrapper .product-img .aligner img", :base_genero => ".body-holder #features-box #caracteristicas .description-list"})
robolek.insert({:url => "http://www.stoza.com.br/", :produtos => "(http://www.stoza.com.br/camiseta/)(.+)", :robots => "http://www.stoza.com.br/robots.txt", :base_preco => ".container .row-fluid .span6 .summary .price .amount", :base_foto => ".container .row-fluid .span6 .flexslider_galeria .slides img", :base_genero => ""})
robolek.insert({:url => "http://www.farfetch.com.br/", :produtos => "(http://www.farfetch.com.br/shopping/)(.+)(storeid=)(.+)", :robots => "http://www.farfetch.com.br/robots.txt", :base_preco => ".content .container #productDescriptionWrapper #productItemDesc #ContentPlaceBody_TemplateBody_lbPrice", :base_foto => ".content .container #productZoomWrapper #productZoomImg #productZoomImgCarousel .productZoomImgCarousel-IMG img", :base_genero => ".content .container .contentBreadcrumbs"})
#javascript ----> robolek.insert({:url => "http://www.dafiti.com.br/", :produtos => "(http://www.dafiti.com.br/)(.+)(\.html)", :robots => "http://www.dafiti.com.br/robots.txt", :base_preco => ".l-full-content .l-product-sale-information .box-information", :base_foto => ".full-content .l-full-content .l-product-container .product-img-box .product-img-box-image img", :base_genero => ""})

contador = 0
Benchmark.bm do |x|
  x.report("while") do
    while(robolek.fim? == false)
      puts "contador = #{contador}"
      Benchmark.bm do |x|
        x.report("loop_crawl") {robolek.loop_crawl(:next)}
      end
      contador += 1
    end
  end
  
end

robolek.close_db