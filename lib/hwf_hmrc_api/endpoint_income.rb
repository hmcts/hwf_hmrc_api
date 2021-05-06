# frozen_string_literal: true

module HwfHmrcApi
  module EndpointIncome
    def income_paye(access_token, attributes)
      @response = HTTParty.get("#{api_url}/individuals/income/paye",
                               headers: request_headers(access_token),
                               query: {
                                 matchId: attributes[:matching_id],
                                 fromDate: attributes[:from],
                                 toDate: attributes[:to]
                               })
      parse_paye_response
    end

    def income_summary(access_token, attributes)
      @response = HTTParty.get("#{api_url}/individuals/income/sa/summary",
                               headers: request_headers(access_token),
                               query: {
                                 matchId: attributes[:matching_id],
                                 fromTaxYear: attributes[:from],
                                 toTaxYear: attributes[:to]
                               },
                               debug_output: $stdout)
      parse_summary_response
    end

    private

    def parse_paye_response
      parse_standard_error_response if @response.code != 200
      response_hash["paye"]
    rescue JSON::ParserError => e
      raise HwfHmrcApiError.new(e.message, :standard_error)
    end

    def parse_summary_response
      parse_standard_error_response if @response.code != 200
      response_hash["selfAssessment"]
    rescue JSON::ParserError => e
      raise HwfHmrcApiError.new(e.message, :standard_error)
    end
  end
end
