# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module Address
      def addresses(access_token, attributes)
        @response = HTTParty.get("#{api_url}/individuals/details/addresses",
                                 headers: request_headers(access_token, "1.0"),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromDate: attributes[:from],
                                   toDate: attributes[:to]
                                 })
        parse_addresses_response
      end

      private

      def parse_addresses_response
        parse_standard_error_response if @response.code != 200
        response_hash["residences"]
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end
    end
  end
end
