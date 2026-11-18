# frozen_string_literal: true

require_relative "hwf_hmrc_api/connection"
require_relative "hwf_hmrc_api/connection_attribute_validation"
require_relative "hwf_hmrc_api/mock"

module HwfHmrcApi
  MOCK_CONNECTION = "mock_hmrc"

  class << self
    include ConnectionAttributeValidation

    # Mandatory attributes
    # :hmrc_secret - String
    # :totp_secret - String
    # :client_id - String
    # Optional attributes - expires_in is mandatory if token is provided
    # :expires_in - Time or String (YYYY-mm-dd)
    # :access_token - String
    #
    # HMRC_API_CONNECTION=mock_hmrc answers from test individuals instead of
    # calling HMRC, and needs none of the attributes above. Any other value, or
    # none, uses the real connection.
    def new(connection_attributes)
      mock_connection? ? warn_mock_connection : validate_mandatory_attributes(connection_attributes)
      HwfHmrcApi::Connection.new(connection_attributes)
    end

    def mock_connection?
      ENV.fetch("HMRC_API_CONNECTION", nil) == MOCK_CONNECTION
    end

    private

    def warn_mock_connection
      $stdout.puts "[HwfHmrcApi] HMRC_API_CONNECTION=#{MOCK_CONNECTION}: " \
                   "answering from test individuals, HMRC is not called"
    end
  end
end
