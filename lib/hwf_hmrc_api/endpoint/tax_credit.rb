# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module TaxCredit
      def child_tax_credits(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/benefits-and-credits/child-tax-credit",
                                 headers: request_headers(header_info, "1.0"),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromDate: attributes[:from],
                                   toDate: attributes[:to]
                                 })
        parse_tax_response
      end

      def working_tax_credits(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/benefits-and-credits/working-tax-credit",
                                 headers: request_headers(header_info, "1.0"),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromDate: attributes[:from],
                                   toDate: attributes[:to]
                                 })
        parse_tax_response
      end

      private

      def parse_tax_response
        parse_standard_error_response if @response.code != 200
        response_hash["applications"]
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end
    end
  end
end
