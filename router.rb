require 'route'

class Router
  attr_reader :routes

  def initialize
    @routes = Hash.new { |hash, key| hash[key] = [] }
  end

  def config &block
    instance_eval &block
  end

  def get(path, options = {})
    @routes[:get] << [path, parse_to(options[:to])]
  end

  def route_for(env)
    path   = env["PATH_INFO"]
    method = env["REQUEST_METHOD"].downcase.to_sym
    routes = get(path, {:to => path})

    route_array = routes.detect do |route|
      case route.first
      when String
        path == route.first
      when Regexp
        path =~ route.first
      end
    end
    return Route.new(route_array) if route_array
    return nil #No route matched
  end

  private
  def parse_to(str)
    _, type, uid = str.split("/")
    { :type => type, :uid => uid }
  end
end
