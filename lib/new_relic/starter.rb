# frozen_string_literal: true

require 'new_relic/agent'

module NewRelic
  # NewRelic::Starter starts the New Relic agent by calling
  # {NewRelic::Agent.manual_start}.
  class Starter
    # NewRelic::Starter::Error is a base class for errors.
    class Error < StandardError; end

    autoload :Latch, 'new_relic_starter'
    autoload :Rack, 'new_relic/starter/rack'

    # Return a new {Starter} object.
    #
    # @param latch [NewRelic::Starter::Latch] the latch object
    # @return [NewRelic::Starter] A new starter object
    def initialize(latch)
      @latch = latch
      @started = false
    end

    # Starts the new Relic agent if the agent is not started and the latch is
    # opened.
    #
    # @return [Boolean] true if the new Relic agent is started
    def start
      return false if @started || !@latch.opened?

      NewRelic::Agent.manual_start
      @started = true
    end
  end
end
