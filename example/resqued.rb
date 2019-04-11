# frozen_string_literal: true

before_fork do
  Resque.redis = ENV['REDIS_URL']
  require 'new_relic/starter'
  latch = NewRelic::Starter::Latch.new(ENV['NEW_RELIC_STARTER_LATCH_PATH'])
  starter = NewRelic::Starter.new(latch)
  Resque.before_fork do
    starter.start(dispatcher: :resque, start_channel_listener: true)
  end
end

worker
worker
