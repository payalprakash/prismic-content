require 'router'

class BrainRack
  attr_reader :router

  def initialize
    @router = Router.new
  end
end
