# frozen_string_literal: true

require 'active_support/concern'

module Cacheable
  extend ActiveSupport::Concern

  def remove_from_cache
    Rails.cache.delete([self.class.name, id])
  end

  class_methods do
    def find_from_cache(game_id)
      Rails.cache.fetch([name, game_id]) { find_by_id game_id }
    end
  end
end
