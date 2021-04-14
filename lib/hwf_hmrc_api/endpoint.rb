# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    class << self
      require "httparty"
      require "uuid"

      def token(secret, client_id)
        response = HTTParty.post("#{api_url}/oauth/token",
                                 headers: { "content-type" => "application/x-www-form-urlencoded" },
                                 body: { client_secret: secret, client_id: client_id,
                                         grant_type: "client_credentials" })

        process_response(response)
      end

      def match_user(access_token, user_info)
        response = HTTParty.post("#{api_url}/individuals/matching",
                                 headers: { "Content-Type": "application/json",
                                            "correlationId" => UUID.new.generate,
                                            "Accept" => "application/vnd.hmrc.2.0+json",
                                            "Authorization" => "Bearer #{access_token}" },
                                 body: user_info.to_json,
                                 debug_output: $stdout)

        parse_matching_user_response(response)
      end

      private

      def process_response(response)
        response_hash = JSON.parse(response.to_s)
        if response.code == 403
          raise HwfHmrcApiError.new("API call error: #{response_hash["code"]}: #{response_hash["message"]}",
                                    :response_error)
        elsif response.code != 200
          raise HwfHmrcApiError.new("API call error: #{response_hash["error"]}: #{response_hash["error_description"]}",
                                    :response_error)
        end

        response_hash
      end

      def parse_matching_user_response(response)
        if response.code == 200
          id = JSON.parse(response.to_s)["_links"]["individual"]["href"].sub("/individuals/matching/", "")
          { matching_id: id }
        else
          process_response(response)
        end
      end

      def api_url
        "https://test-api.service.hmrc.gov.uk"
      end
    end
  end
end
