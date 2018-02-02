#!/usr/bin/env ruby

require 'prismic'
require 'time'
require 'json'
require 'rack'
require 'linkresolver'


api = Prismic.api('https://content-ws-trial.prismic.io/api')
search_form = api.form('everything')
master_ref = search_form.api.json['refs'][0]
ref =  Prismic::Ref.new(
  master_ref['id'],
  master_ref['ref'],
  master_ref['label'],
  master_ref['isMasterRef']
)

linkresolver = ::LinkResolver.new
link_resolver = linkresolver.get(ref)

# results = search_form.submit(ref)
# puts results.inspect
response = Prismic::Predicates.at("document.type", "articles")
response = api.query(
    response,
    { "orderings" => "[my.articles.uid]" }
)
response = api.all()
types = response.results.map{ |d| d.type }
puts "#{types.uniq}"

document = api.getByUID("articles", "cloud-account-email-services")
puts "Title: #{document.fragments['title'].blocks[0].text}"
puts "Text: #{document.fragments['description'].blocks[0].text}"

#document = api.getByUID('documentation-home', 'webscale-support-center')
#puts document.fragments

link = link_resolver.link_to(document)
puts "Link: #{link}"

puts document.as_html(link_resolver)

app = Proc.new do |env|
puts env
  [
    '200', 
    {'Content-Type' => 'text/html'}, 
    [ 
      document.fragments['title'].as_html(link_resolver),
      document.fragments['description'].as_html(link_resolver)
    ]
  ]
end
Rack::Handler::WEBrick.run app

puts document.fragments['title'].as_html(link_resolver)
puts document.fragments['description'].as_html(link_resolver)

