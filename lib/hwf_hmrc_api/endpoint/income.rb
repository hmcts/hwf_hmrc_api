# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module Income
      def income_paye(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/paye",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromDate: attributes[:from],
                                   toDate: attributes[:to]
                                 })
        parse_paye_response
      end

      def income_summary(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/sa/summary",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromTaxYear: attributes[:from],
                                   toTaxYear: attributes[:to]
                                 })
        parse_self_assessment_response
      end

      def income_interest_dividends(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/sa/interests-and-dividends",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromTaxYear: attributes[:from],
                                   toTaxYear: attributes[:to]
                                 })
        parse_self_assessment_response
      end

      def income_self_employments(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/sa/self-employments",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromTaxYear: attributes[:from],
                                   toTaxYear: attributes[:to]
                                 })
        parse_self_assessment_response
      end

      def income_uk_properties(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/sa/uk-properties",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromTaxYear: attributes[:from],
                                   toTaxYear: attributes[:to]
                                 })
        parse_self_assessment_response
      end

      def income_foreign(header_info, attributes)
        @response = HTTParty.get("#{api_url}/individuals/income/sa/foreign",
                                 headers: request_headers(header_info),
                                 query: {
                                   matchId: attributes[:matching_id],
                                   fromTaxYear: attributes[:from],
                                   toTaxYear: attributes[:to]
                                 })
        parse_self_assessment_response
      end

      private

      def parse_paye_response
        parse_standard_error_response if @response.code != 200
        response_hash["paye"]
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end

      def parse_self_assessment_response
        parse_standard_error_response if @response.code != 200
        response_hash["selfAssessment"]
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end
    end
  end
end
