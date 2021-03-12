# frozen_string_literal: true

require 'rails_helper'

describe 'POST api/v1/games/', type: :request do
  let(:game) { Game.last }

  describe 'POST create' do
    it 'returns a successful response' do
      post api_v1_games_path

      expect(response).to have_http_status(:success)
    end

    it 'creates the game' do
      expect { post api_v1_games_path }.to change(Game, :count).by(1)
    end

    it 'returns the game' do
      post api_v1_games_path

      expect(json[:id]).to eq(game.id)
    end
  end
end
