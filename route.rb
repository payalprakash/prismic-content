require 'response'

class Route
  attr_accessor :type, :path, :uid
  def initialize(route_array)
    @path = route_array.first
    @type = route_array.last[:type]
    @uid  = route_array.last[:uid]
    handle_requires
  end

  def klass
    str = "App::" + type.gsub(/[_-]/,'').capitalize
    Method.const_get(str)
  end

  def execute(env)
    klass.new(type, uid)
  end

  def handle_requires
    return if type == 'favicon.ico'
    require File.join(File.dirname(__FILE__), 'app', 'controllers', type.downcase + '.rb')
  end
end
