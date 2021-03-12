# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameService do
  let(:subject) { described_class }

  before(:each) { Rails.cache.clear }

  it 'should have NUMBER_OF_PINS and NUMBER_OF_FRAMES' do
    expect(GameService::NUMBER_OF_PINS).to eq 10
    expect(GameService::NUMBER_OF_FRAMES).to eq 10
  end

  context 'knocking only available pins' do
    context 'on a normal frame' do
      it 'should knock only available number of pins' do
        expect { roll([[]], 11) }.to raise_error subject::AvailablePinsError
        expect { roll([[]], -1) }.to raise_error subject::AvailablePinsError
      end

      it 'should knock only available number of pins after a throw' do
        expect { roll_many(1, [7, 4]) }.to raise_error subject::AvailablePinsError
      end
    end

    context 'on an ending frame' do
      before :each do
        @frames = roll_many(9, [3, 5])
      end

      it 'should knock only available number of pins after a normal throw' do
        expect(score(@frames)).to eq 72
        expect { roll_many(1, [3, 8], @frames) }.to raise_error subject::AvailablePinsError
      end

      it 'should knock only available number of pins after a strike' do
        frames = roll_many(1, [10], @frames)
        expect { roll(frames, 11) }.to raise_error subject::AvailablePinsError

        frames = roll(frames, 5)
        expect { roll(frames, 6) }.to raise_error subject::AvailablePinsError

        frames = roll(frames, 5)
        expect { roll(frames, 1) }.to raise_error subject::GameOverError
      end

      it 'should knock only available number of pins after a spare' do
        frames = roll_many(1, [5, 5], @frames)
        expect { roll(frames, 11) }.to raise_error subject::AvailablePinsError

        frames = roll(frames, 5)
        expect { roll(frames, 1) }.to raise_error subject::GameOverError
      end
    end
  end

  context 'one frame' do
    it 'should show correct score' do
      frames = roll_many(1, [4, 3])
      expect(score(frames)).to eq 7
      expect(frames).to eq [[4, 3], []]
    end
  end

  context 'multiple games' do
    it 'should show correct score' do
      frames = roll_many(1, [4, 3, 4, 3])
      expect(frames).to eq [[4, 3], [4, 3], []]
    end

    context 'with a strike' do
      it 'should have correct score' do
        frames = roll_many(1, [10, 5, 3])
        expect(score(frames)).to eq 26
        expect(frames).to eq [[10, 5, 3], [5, 3], []]
      end
    end

    context 'with a spare' do
      it 'should have correct score' do
        frames = roll_many(1, [4, 6, 5, 3])
        expect(score(frames)).to eq 23
        expect(frames).to eq [[4, 6, 5], [5, 3], []]
      end
    end
  end

  context 'all frames' do
    before :each do
      @frames = roll_many(9, [5, 3])
    end

    it 'should not allow more throws' do
      frames = roll_many(1, [5, 3], @frames)
      expect(score(frames)).to eq 80
      expect(frames).to eq [[5, 3]] * 10
      expect { roll(frames, 3) }.to raise_error subject::GameOverError
    end

    it 'should handle strike in last frame' do
      frames = roll_many(1, [10, 3, 4], @frames)
      expect(score(frames)).to eq 89
      expect(frames).to eq([[5, 3]] * 9 << [10, 3, 4])
      expect { roll(frames, 4) }.to raise_error subject::GameOverError
    end

    it 'should handle spare in last frame' do
      frames = roll_many(1, [4, 6, 3], @frames)
      expect(score(frames)).to eq 85

      expect(frames).to eq([[5, 3]] * 9 << [4, 6, 3])
      expect { roll(frames, 4) }.to raise_error subject::GameOverError
    end

    it 'should allow 3 strikes in last frame' do
      frames = roll_many(1, [10, 10, 10], @frames)
      expect(score(frames)).to eq 102
      expect(frames).to eq([[5, 3]] * 9 << [10, 10, 10])
    end
  end

  context 'different test cases' do
    specify '2 strikes in a row' do
      frames = roll_many(1, [5, 3, 10, 10, 3, 4])
      expect(score(frames)).to eq 55
    end

    specify 'with strikes and spares in a row' do
      frames = roll_many(1, [5, 3, 10, 2, 8, 1, 9, 3, 4])
      expect(score(frames)).to eq 59
    end

    specify 'with strike at last 2 frames' do
      frames = roll_many(8, [5, 3])
      frames = roll_many(1, [10, 10, 5, 3], frames)
      expect(score(frames)).to eq 107
    end

    specify 'with spare at last frame' do
      frames = roll_many(9, [5, 3])
      frames = roll_many(1, [4, 6], frames)

      frames = subject.new(frames, 7).call
      expect(score(frames)).to eq 89
    end

    specify 'custome - youtube' do
      frames = roll_many(1, [8, 2, 7, 3, 3, 4, 10, 2, 8, 10, 10, 8, 0, 10, 8, 2, 9])
      expect(score(frames)).to eq 170
    end
  end
end

def roll_many(n, pins, frames = [[]])
  n.times { pins.map { |p| frames = roll(frames, p) } }
  frames
end

def roll(f, p)
  subject.new(f, p).call
end

def score(frames)
  frames.flatten.sum
end
