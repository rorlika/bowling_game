# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { Game.new }

  before(:each) { Rails.cache.clear }

  context 'model from db' do
    it 'should have initial score and frames' do
      expect(Game.create.score).to eq 0
      expect(Game.create.frames).to eq [[]]
    end

    it 'should reload same data from DB' do
      current_game = Game.create
      expect(current_game.score).to eq 0
      expect(current_game.frames).to eq [[]]
    end

    it 'should cache' do
      game
      expect(Game).to receive(:find_by_id).and_call_original
      Game.find_from_cache game.id

      expect(Game).not_to receive(:find_by_id).and_call_original
      Game.find_from_cache game.id
    end
  end
end
