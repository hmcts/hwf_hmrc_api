# frozen_string_literal: true

module HwfHmrcApi
  module EndpointToken
    require "uuid"

    def token(secret, client_id)
      @response = HTTParty.post("#{api_url}/oauth/token",
                                headers: { "content-type" => "application/x-www-form-urlencoded" },
                                body: { client_secret: secret, client_id: client_id,
                                        grant_type: "client_credentials" })

      process_token_response
    end

    private

    def process_token_response
      return response_hash if @response.code == 200

      message = "API: #{response_hash["error"]} - #{response_hash["error_description"]}"
      raise HwfHmrcApiError.new(message, :token_error) if [401, 400, 500].include?(@response.code)
    rescue StandardError => e
      raise HwfHmrcApiError.new(e.message, :standard_error)
    end
  end
end
