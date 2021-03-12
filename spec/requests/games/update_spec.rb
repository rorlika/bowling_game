require 'rails_helper'

describe 'PUT api/v1/games/:id', type: :request do
  let(:game) { Game.create }

  context 'with valid params' do
    let(:params) { { game: { knocked_pins: 5 } } }

    it 'returns success' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(response).to have_http_status(:success)
    end

    it 'updates the game' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(game.reload.score).to eq(params[:game][:knocked_pins])
    end

    it 'returns the game' do
      put api_v1_game_path(game.id), params: params, as: :json

      expect(json[:score]).to eq game.reload.score
      expect(json[:frames]).to eq game.reload.frames
    end
  end

  context 'with invalid data' do
    let(:params) { { game: { knocked_pins: 11 } } }

    it 'does not return success' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(response).to_not have_http_status(:success)
    end

    it 'does not update the game' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(game.reload.score).to_not eq(params[:game][:knocked_pins])
    end

    it 'returns the error' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(json[:error][:message]).to eq("Can't knock more pins than available.")
    end
  end

  context 'when game is over' do
    let(:params) { { game: { knocked_pins: 4 } } }

    before do
      20.times do
        put api_v1_game_path(game.id, params)
      end
    end

    it 'returns the error' do
      put api_v1_game_path(game.id), params: params, as: :json
      expect(json[:error][:message]).to eq('Game is over.')
    end
  end

  context 'with missing params' do
    it 'returns the missing params error' do
      put api_v1_game_path(game.id), params: {}, as: :json
      expect(json[:error][:message]).to eq('A required param is missing')
    end
  end
end
