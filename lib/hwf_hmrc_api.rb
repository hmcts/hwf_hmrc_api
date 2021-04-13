# frozen_string_literal: true

require_relative "hwf_hmrc_api/version"
require_relative "hwf_hmrc_api/connection"
require_relative "hwf_hmrc_api/connection_attribute_validation"

module HwfHmrcApi
  class << self
    include ConnectionAttributeValidation

    def new(connection_attributes)
      validate_mandatory_attributes(connection_attributes)
      HwfHmrcApi::Connection.new(connection_attributes)
    end

    private

  end
end
