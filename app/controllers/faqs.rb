require 'prismic'
require 'time'
require 'linkresolver'

module App
  class Faqs
    def initialize(type, uid)
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
      @link_resolver = linkresolver.get(ref)
      @document = api.getByUID(type, uid)
    end

    def get_content
      content = Array.new()
      @document.fragments.each do |key, value|
        value.blocks.each do |v|
          content.push(v.as_html(@link_resolver))
        end
      end
      return content
    end

    def rack_response
      [
        '200',
        {'Content-Type' => 'text/html'},
        get_content
      ]
    end
  end
end
