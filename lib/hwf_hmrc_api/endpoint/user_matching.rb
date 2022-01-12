# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module UserMatching
      def match_user(header_info, user_info)
        @response = HTTParty.post("#{api_url}/individuals/matching",
                                  headers: request_headers(header_info, "2.0"),
                                  body: user_info.to_json)

        parse_matching_user_response
      end

      private

      def parse_matching_user_response
        parse_standard_error_response if @response.code != 200
        id = response_hash["_links"]["individual"]["href"].sub("/individuals/matching/", "")
        { matching_id: id }
      rescue JSON::ParserError => e
        raise HwfHmrcApiError.new(e.message, :standard_error)
      end
    end
  end
end
