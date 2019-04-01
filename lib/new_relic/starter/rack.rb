# frozen_string_literal: true

require 'new_relic/agent'

module NewRelic
  class Starter
    # NewRelic::Starter::Rack is a Rack middleware that provides an endpoint to
    # start the New Relic agent.
    class Rack
      # Returns a new {Rack} which implements the Rack interface.
      #
      # @param app [Object] the Rack application
      # @param latch [NewRelic::Starter::Latch] the latch object
      # @param path [String] the path of the endpoint to start the New Relic
      #   agent
      # @return [NewRelic::Starter::Rack] A new rack middleware object
      def initialize(app, latch: Latch.new, path: nil)
        @app = app
        @latch = latch
        @path = path || '/_new_relic/start'
        @starter = Starter.new(latch)
      end

      # Opens a latch and start the New Relic agent if the path of the request
      # matches with the path of the endpoint.
      #
      # When the path doesn't match, if a latch is opened, the agent is started
      # before calling the next application.
      #
      # @param env [Hash] the Rack environment
      # @return [Array] the Rack response
      def call(env)
        if env['PATH_INFO'] == @path
          handle
        else
          @starter.start
          @app.call(env)
        end
      end

      private

      def handle
        @latch.open
        headers = { 'Content-Type' => 'text/plain' }
        body = if @starter.start
                 'Started the New Relic agent.'
               else
                 'The New Relic agent is already started.'
               end
        [200, headers, [body]]
      end
    end
  end
end
