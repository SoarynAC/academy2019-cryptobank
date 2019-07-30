# frozen_string_literal: true

require_relative 'server'

run Rack::URLMap.new(
  '/' => Public,
  '/api' => Api
)
