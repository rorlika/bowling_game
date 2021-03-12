# frozen_string_literal: true

class GameService
  class GameOverError < StandardError
    def message
      'Game is over.'
    end
  end

  class AvailablePinsError < StandardError
    def message
      "Can't knock more pins than available."
    end
  end

  NUMBER_OF_PINS = 10
  NUMBER_OF_FRAMES = 10

  attr_reader :frames, :knocked_pins

  def initialize(frames, knocked_pins)
    @frames = frames
    @knocked_pins = knocked_pins
  end

  def call
    raise GameOverError if game_over?
    raise AvailablePinsError unless knocked_pins.between?(0, avaliable_pins)

    frames.last << knocked_pins
    fill_open_frames_with knocked_pins
    frames << [] if frame_completed?(frames.last) && !game_over?
    frames
  end

  private

  def game_over?
    frames.size == NUMBER_OF_FRAMES && frame_completed?(frames.last)
  end

  def fill_open_frames_with(value)
    frames.map do |frame|
      next if frame.equal?(frames.last)

      frame << value if strike?(frame) && frame.size <= 2
      frame << value if spare?(frame) && frame.size == 2
    end
  end

  def strike?(frame)
    frame[0] == NUMBER_OF_PINS
  end

  def double_strike?(frame)
    [frame[0], frame[1]].compact.sum == NUMBER_OF_PINS * 2
  end

  def spare?(frame)
    [frame[0], frame[1]].compact.sum == NUMBER_OF_PINS
  end

  def ending_frame?(frame)
    frames.size == NUMBER_OF_FRAMES && frames.last.equal?(frame)
  end

  def frame_completed?(frame)
    return ending_frame_completed?(frame) if ending_frame?(frame)
    return true if frame.nil? || frame.size == 2 || strike?(frame)

    false
  end

  def ending_frame_completed?(frame)
    frame.size == if strike?(frame) || spare?(frame)
                    3
                  else
                    2
                  end
  end

  def avaliable_pins
    current_frame = frames.last
    current_frame_score = current_frame.to_a.sum

    if ending_frame?(current_frame)
      return (NUMBER_OF_PINS * 3 - current_frame_score) if double_strike?(current_frame)
      return (NUMBER_OF_PINS * 2 - current_frame_score) if strike?(current_frame) || spare?(current_frame)
    end

    NUMBER_OF_PINS - current_frame_score
  end
end
