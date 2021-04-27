# frozen_string_literal: true

require_relative "hwf_hmrc_api/version"
require_relative "hwf_hmrc_api/connection"
require_relative "hwf_hmrc_api/connection_attribute_validation"

module HwfHmrcApi
  class << self
    include ConnectionAttributeValidation
    # Mandatory attributes
    # :hmrc_secret - String
    # :totp_secret - String
    # :client_id - String
    # Optional attributes - expires_in is mandatory if token is provided
    # :expires_in - Time or String (YYYY-mm-dd)
    # :access_token - String
    def new(connection_attributes)
      validate_mandatory_attributes(connection_attributes)
      HwfHmrcApi::Connection.new(connection_attributes)
    end
  end
end
