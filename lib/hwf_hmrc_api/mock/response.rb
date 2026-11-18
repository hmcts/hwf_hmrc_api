# frozen_string_literal: true

require "json"

module HwfHmrcApi
  module Mock
    # The two things the endpoints read from an HTTP response: the status code and the body
    Response = Struct.new(:code, :body) do
      def self.json(code, payload)
        new(code, payload.to_json)
      end

      # HMRC errors look like {"code":"MATCHING_FAILED","message":"..."}
      def self.error(code, error_code, message)
        json(code, code: error_code, message: message)
      end

      def to_s
        body
      end
    end
  end
end
