# frozen_string_literal: true

require 'new_relic/starter/rack'

module NewRelic
  class Starter
    # NewRelic::Starter::Railtie implements a railtie which creates an
    # initializer to add the Rack middleware to the middleware stack with the
    # default options.
    class Railtie < Rails::Railtie
      initializer 'new_relic-starter.middleware' do |app|
        app.middleware.use NewRelic::Starter::Rack
      end
    end
  end
end
