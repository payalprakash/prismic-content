require 'prismic'

class LinkResolver
  def initialize
    @link_resolver = nil
  end

  def get(ref)
    @link_resolver ||= Prismic::LinkResolver.new(ref) do |link|
      # URL for the articles type
      if link.type == "articles"
        "/articles/" + link.uid
      # URL for the faq type
      elsif link.type == "faqs"
        "/faqs/" + link.uid
      # URL for the user_guide type
      elsif link.type == "user_guide"
        "/user_guide/" + link.uid
      # Default case for all other types
      else
        "/"
      end
    end
  end
end
