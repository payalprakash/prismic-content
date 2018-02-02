require 'router'
require 'brainrack'

class RequestController
  def call(env)
    r = BrainRack.new
    route = r.router.route_for(env)
    if route
      if env['PATH_INFO'] == '/favicon.ico'
        return [
          200,
          { 'Content-Type' => 'text/html' },
          [
            "<link rel='icon' href='public/images/favicon.ico' />"
          ]
        ]
      end
      response = route.execute(env)
      return response.rack_response
    else
      return [404, {}, []]
    end
  end
end
