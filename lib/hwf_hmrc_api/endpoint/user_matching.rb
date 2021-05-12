# frozen_string_literal: true

module HwfHmrcApi
  module Endpoint
    module UserMatching
      def match_user(access_token, user_info)
        @response = HTTParty.post("#{api_url}/individuals/matching",
                                  headers: { "Content-Type": "application/json",
                                             "correlationId" => UUID.new.generate,
                                             "Accept" => "application/vnd.hmrc.2.0+json",
                                             "Authorization" => "Bearer #{access_token}" },
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
