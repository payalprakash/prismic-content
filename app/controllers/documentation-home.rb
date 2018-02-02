require 'prismic'
require 'time'
require 'linkresolver'

module App
  class Documentationhome
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
      content.push(@document.fragments['document_page_title'].as_html(@link_resolver))
      @document.fragments['body'].slices.each do |s|
        content.push("<h3> #{s.slice_type.split('_').map(&:capitalize).join(' ')} </h3>")
        s.non_repeat.each do |key, value|
          value.blocks.each do |v|
            content.push(v.as_html(@link_resolver))
          end
        end
        s.repeat.group_documents.each do |g|
          g.fragments.each do |key, value|
            content.push(value.as_html(@link_resolver))
            #puts "blaaah: #{value.as_html(@link_resolver)}"
            #text = value.slug.split('_').map(&:capitalize).join(' ')
            #content.push("<a href='#{value.slug}'>#{text}</a>")
            content.push("</br>")
          end
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
