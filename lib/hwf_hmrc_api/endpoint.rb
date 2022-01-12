# frozen_string_literal: true

require "hwf_hmrc_api/endpoint/income"
require "hwf_hmrc_api/endpoint/user_matching"
require "hwf_hmrc_api/endpoint/token"
require "hwf_hmrc_api/endpoint/tax_credit"
require "hwf_hmrc_api/endpoint/employment"
require "hwf_hmrc_api/endpoint/address"

module HwfHmrcApi
  module Endpoint
    class << self
      require "httparty"
      include Token
      include UserMatching
      include Income
      include TaxCredit
      include Employment
      include Address

      private

      def request_headers(header_info, version = "2.0")
        access_token = header_info[:access_token]
        uuid = header_info[:correlation_id] || SecureRandom.uuid
        {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.#{version}+json",
          "Authorization" => "Bearer #{access_token}",
          "correlationId" => uuid
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
        ENV["HMRC_API_URL"]
      end
    end
  end
end
