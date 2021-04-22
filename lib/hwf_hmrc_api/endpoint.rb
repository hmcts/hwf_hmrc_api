# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    class << self
      require "httparty"
      require "uuid"

      def token(secret, client_id)
        @response = HTTParty.post("#{api_url}/oauth/token",
                                  headers: { "content-type" => "application/x-www-form-urlencoded" },
                                  body: { client_secret: secret, client_id: client_id,
                                          grant_type: "client_credentials" })

        process_token_response
      end

      def match_user(access_token, user_info)
        @response = HTTParty.post("#{api_url}/individuals/matching",
                                  headers: { "Content-Type": "application/json",
                                             "correlationId" => UUID.new.generate,
                                             "Accept" => "application/vnd.hmrc.2.0+json",
                                             "Authorization" => "Bearer #{access_token}" },
                                  body: user_info.to_json,
                                  debug_output: $stdout)

        parse_matching_user_response
      end

      private

      def process_token_response
        return response_hash if @response.code == 200

        message = "API: #{response_hash["error"]} - #{response_hash["error_description"]}"
        raise HwfHmrcApiError.new(message, :token_error) if [401, 400, 500].include?(@response.code)
      rescue StandardError => ess
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end

      def parse_standard_error_response
        message = "API: #{response_hash["code"]} - #{response_hash["message"]}"
        raise HwfHmrcApiError.new(message, :invalid_request) if [403, 400].include?(@response.code)
      end

      def parse_matching_user_response
        parse_standard_error_response if @response.code != 200
        id = response_hash["_links"]["individual"]["href"].sub("/individuals/matching/", "")
        { matching_id: id }
      rescue StandardError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end

      def response_hash
        JSON.parse(@response.to_s)
      end

      def api_url
        "https://test-api.service.hmrc.gov.uk"
      end
    end
  end
end
