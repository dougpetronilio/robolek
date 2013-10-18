require 'webmock/cucumber'
require "webmock"

include WebMock::API

def cria_mock(url, links, code)
  options = {:body => cria_body(url, links), :content_type => "text/html", :status => [code, "OK"]}
  
  stub_request(:get, "#{url}robots.txt").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RoboYep'}).to_return({:body=> "User-agent: * \n Allow: /*", :content_type => "text"}, :status => [200, "OK"])
  stub_request(:get, url + "").with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).to_return(options)
end

def cria_mock_redirecionamento(url, links, code = 302, redirecionamento)
  stub_request(:get, url + "").to_return(:status => code, :body => "", :headers => {'Location' => redirecionamento})
  stub_request(:get, "#{url}robots.txt").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RoboYep'}).to_return({:body=> "User-agent: * \n Allow: /*", :content_type => "text"}, :status => [200, "OK"])
  cria_mock(redirecionamento, links, 200)
end

def cria_body(url, links)
  body = "<html><body>"
  links.each { |link| body += "<a href=\"#{url}#{link}\"></a>"} if links
  body += "</body></html>"
  body
end