# frozen_string_literal: true

RSpec.describe NewRelic::Starter::Rack do
  describe '#call' do
    it "doesn't start the New Relic agent if the latch is not opened" do
      expect(NewRelic::Agent).not_to receive(:manual_start)
      app = ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['foo']] }
      middleware = described_class.new(app)
      env = { 'PATH_INFO' => '/foo' }

      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['foo'])
    end

    it 'starts the New Relic agent if the latch is opened' do
      expect(NewRelic::Agent).to receive(:manual_start).once
      app = ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['foo']] }
      latch = NewRelic::Starter::Latch.new.tap(&:open)
      middleware = described_class.new(app, latch: latch)
      env = { 'PATH_INFO' => '/foo' }

      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['foo'])
    end

    it 'starts the New Relic agent and opens the latch if the path of the request is "/_new_relic/start"' do
      expect(NewRelic::Agent).to receive(:manual_start).once
      app = ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['foo']] }
      latch = NewRelic::Starter::Latch.new
      middleware = described_class.new(app, latch: latch)
      env = { 'PATH_INFO' => '/_new_relic/start' }

      status, headers, body = middleware.call(env)
      expect(latch).to be_opened
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['Started the New Relic agent.'])
    end

    it 'starts the New Relic agent and opens the latch if the path of the request matches with the configured path' do
      expect(NewRelic::Agent).to receive(:manual_start).once
      app = ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['foo']] }
      latch = NewRelic::Starter::Latch.new
      middleware = described_class.new(app, latch: latch, path: '/foo')
      env = { 'PATH_INFO' => '/foo' }

      status, headers, body = middleware.call(env)
      expect(latch).to be_opened
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['Started the New Relic agent.'])
    end

    it "doesn't start the New Relic agent if it's already started" do
      expect(NewRelic::Agent).to receive(:manual_start).once
      app = ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['foo']] }
      latch = NewRelic::Starter::Latch.new.tap(&:open)
      middleware = described_class.new(app, latch: latch)
      env = { 'PATH_INFO' => '/foo' }

      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['foo'])

      env = { 'PATH_INFO' => '/_new_relic/start' }
      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(headers).to eq('Content-Type' => 'text/plain')
      expect(body).to eq(['The New Relic agent is already started.'])
    end
  end
end
