# frozen_string_literal: true

require 'new_relic/starter'
latch = NewRelic::Starter::Latch.new(ENV['NEW_RELIC_STARTER_LATCH_PATH'])
use NewRelic::Starter::Rack, latch: latch
run ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
