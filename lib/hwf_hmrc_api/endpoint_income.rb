# frozen_string_literal: true

module HwfHmrcApi
  module EndpointIncome
    def income_paye(access_token, attributes)
      @response = HTTParty.get("#{api_url}/individuals/income/paye",
                               headers: request_headers(access_token),
                               query: {
                                 matchId: attributes[:matching_id],
                                 fromDate: attributes[:from_date],
                                 toDate: attributes[:to_date]
                               },
                               debug_output: $stdout)
      parse_paye_response
    end

    private

    def parse_paye_response
      parse_standard_error_response if @response.code != 200
      response_hash["paye"]
    rescue JSON::ParserError => e
      raise HwfHmrcApiError.new(e.message, :standard_error)
    end
  end
end
