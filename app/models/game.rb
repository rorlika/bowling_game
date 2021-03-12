# frozen_string_literal: true

class Game < ActiveRecord::Base
  include Cacheable

  serialize :frames, Array

  before_save do
    self.score = frames.flatten.sum
    self.frames = [[]] if frames.empty?
    remove_from_cache
  end
end
