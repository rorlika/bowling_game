# frozen_string_literal: true

module Api
  module Shared
    module ErrorHandler
      def render_error(message, status)
        status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
        render json: { error: { status: status_code, message: message } }, status: status
      end

      def not_found
        render_error(I18n.t('errors.messages.not_found'), :not_found)
      end

      def bad_request
        render_error(I18n.t('errors.messages.bad_request'), :bad_request)
      end

      def parameter_missing
        render_error(I18n.t('errors.messages.parameter_missing'), :unprocessable_entity)
      end
    end
  end
end
