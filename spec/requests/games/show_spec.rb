# frozen_string_literal: true

require 'rails_helper'

describe 'GET api/v1/games/:id', type: :request do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }
  let(:game) { Game.create }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  subject { get api_v1_game_path(game.id), as: :json }

  it 'returns success' do
    subject
    expect(response).to have_http_status(:success)
  end

  it "returns the game's data" do
    subject

    expect(json[:score]).to eq(game.score)
    expect(json[:frames]).to eq(game.frames)
  end

  it 'should cache the response' do
    subject

    expect(cache.exist?("Game/#{game.id}")).to be(true)
  end

  context 'when record is not found' do
    it 'returns status 404 not found' do
      allow_any_instance_of(Api::V1::GamesController).to receive(
        :game
      ).and_raise(ActiveRecord::RecordNotFound)
      subject

      expect(response).to have_http_status(:not_found)
    end
  end
end
