require 'router'
require 'brainrack'

class RequestController
  def call(env)
    r = BrainRack.new
    route = r.router.route_for(env)
    if route
      response = route.execute(env)
      return response.rack_response
    else
      return [404, {}, []]
    end
  end
end
