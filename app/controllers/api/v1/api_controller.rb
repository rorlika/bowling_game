# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      include Shared::ErrorHandler

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :bad_request
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
    end
  end
end
