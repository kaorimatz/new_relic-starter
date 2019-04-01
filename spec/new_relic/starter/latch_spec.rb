# frozen_string_literal: true

require 'tempfile'

RSpec.describe NewRelic::Starter::Latch do
  describe '#open' do
    it 'opens the latch' do
      latch = described_class.new
      expect(latch).not_to be_opened
      pid = Process.fork do
        latch.open
      end
      Process.wait(pid)
      expect(latch).to be_opened
    end
  end

  describe '#opened?' do
    it 'returns false if the latch is not backed by a file' do
      latch = described_class.new
      expect(latch).not_to be_opened
    end

    it "returns false if the latch is backed by a file and the file doesn't exist" do
      path = Tempfile.create(&:path)
      latch = described_class.new(path)
      expect(latch).not_to be_opened
    end

    it 'returns false if the latch is backed by a file and the file is empty' do
      Tempfile.create do |f|
        latch = described_class.new(f.path)
        expect(latch).not_to be_opened
      end
    end

    it 'returns false if the latch is backed by a file and the first byte of the file is 0' do
      Tempfile.create(binmode: true) do |f|
        f.write("\0")
        f.flush
        latch = described_class.new(f.path)
        expect(latch).not_to be_opened
      end
    end

    it 'returns true if the latch is backed by a file and the first byte of the file is 1' do
      Tempfile.create(binmode: true) do |f|
        f.write("\1")
        f.flush
        latch = described_class.new(f.path)
        expect(latch).to be_opened
      end
    end

    it 'returns false if the latch is backed by a file and a single byte 0 is written to the file' do
      Tempfile.create(binmode: true) do |f|
        f.write("\1")
        f.flush
        latch = described_class.new(f.path)
        expect(latch).to be_opened
        f.rewind
        f.write("\0")
        f.flush
        expect(latch).not_to be_opened
      end
    end

    it 'returns true if the latch is backed by a file and a single byte 1 is written to the file' do
      Tempfile.create(binmode: true) do |f|
        latch = described_class.new(f.path)
        expect(latch).not_to be_opened
        f.write("\1")
        f.flush
        expect(latch).to be_opened
      end
    end
  end
end
