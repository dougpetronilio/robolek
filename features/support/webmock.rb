require 'webmock/cucumber'
require "webmock"

include WebMock::API

def cria_mock(url, links, code)
  options = {:body => cria_body(url, links), :content_type => "text/html", :status => [code, "OK"]}
  
  stub_request(:get, url + "").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'www.teste.com', 'User-Agent'=>'Ruby'}).to_return(options)
end

def cria_body(url, links)
  body = "<html><body>"
  links.each { |link| body += "<a href=\"#{url}#{link}\"></a>"} if links
  body += "</body></html>"
  body
end