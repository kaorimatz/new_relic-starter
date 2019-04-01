# frozen_string_literal: true

RSpec.describe NewRelic::Starter do
  describe '#start' do
    it "doesn't start the New Relic agent if the latch is not opened" do
      expect(NewRelic::Agent).not_to receive(:manual_start)
      latch = NewRelic::Starter::Latch.new
      starter = described_class.new(latch)
      expect(starter.start).to eq(false)
    end

    it 'starts the New Relic agent if the latch is opened' do
      expect(NewRelic::Agent).to receive(:manual_start).once
      latch = NewRelic::Starter::Latch.new.tap(&:open)
      starter = described_class.new(latch)
      expect(starter.start).to eq(true)
    end

    it "doesn't start the New Relic agent if it's already started" do
      expect(NewRelic::Agent).to receive(:manual_start).once
      latch = NewRelic::Starter::Latch.new.tap(&:open)
      starter = described_class.new(latch)
      expect(starter.start).to eq(true)
      expect(starter.start).to eq(false)
    end
  end
end
