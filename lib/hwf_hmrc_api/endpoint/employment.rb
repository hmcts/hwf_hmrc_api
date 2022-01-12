# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module Employment
      def employments_paye(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/employments/paye",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromDate: attributes[:from],
                                   toDate: attributes[:to]
                                 })
        parse_employment_response
      end

      private

      def parse_employment_response
        parse_standard_error_response if @response.code != 200
        response_hash["employments"]
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end
    end
  end
end
