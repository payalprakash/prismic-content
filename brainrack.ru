#!/usr/bin/env ruby

require 'rack'
require 'requestcontroller'

Rack::Handler::WEBrick.run(
  RequestController.new,
  :Port => 9000
)
