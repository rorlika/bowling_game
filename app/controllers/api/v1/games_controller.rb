# frozen_string_literal: true

module Api
  module V1
    class GamesController < ApiController
      def create
        create_game
        render :create, status: 201
      end

      def show
        game
        render :show, status: 200
      end

      def update
        frames = GameService.new(game.frames, game_params[:knocked_pins].to_i).call
        game.update(frames: frames)
        render 'show.json'
      rescue GameService::GameOverError, GameService::AvailablePinsError => e
        render_error(e.message, :unprocessable_entity)
      end

      private

      def create_game
        @create_game ||= Game.create
      end

      def game
        @game ||= Game.find_from_cache(params[:id])
      end

      def game_params
        params.require(:game).permit(:knocked_pins)
      end
    end
  end
end
