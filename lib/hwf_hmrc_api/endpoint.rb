# frozen_string_literal: true

require_relative "endpoint_income"
require_relative "endpoint_user_matching"
require_relative "endpoint_token"

module HwfHmrcApi
  module Endpoint
    class << self
      require "httparty"
      include EndpointToken
      include EndpointUserMatching
      include EndpointIncome

      private

      def request_headers(access_token)
        {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.2.0+json",
          "Authorization" => "Bearer #{access_token}",
          "correlationId" => UUID.new.generate
        }
      end

      def response_hash
        JSON.parse(@response.to_s)
      end

      def parse_standard_error_response
        message = "API: #{response_hash["code"]} - #{response_hash["message"]}"

        raise HwfHmrcApiTokenError.new(message, :invalid_token) if @response.code == 401
        raise HwfHmrcApiError.new(message, :invalid_request)
      end

      def api_url
        # "https://api.service.hmrc.gov.uk"
        "https://test-api.service.hmrc.gov.uk"
      end
    end
  end
end
