# frozen_string_literal: true
module Rack::Acme
  class Endpoint
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ::Rack::Request.new(env)

      if (m = request.fullpath.match(%r{\A/.well-known/acme-challenge/(.+)\z}))
        token = m[1]
        content = ::Rack::Acme.cache[token]

        if content
          return [200, {}, [content]]
        else
          return [404, {}, ["No match for #{token}"]]
        end
      else
        @app.call(env)
      end
    end
  end
end
