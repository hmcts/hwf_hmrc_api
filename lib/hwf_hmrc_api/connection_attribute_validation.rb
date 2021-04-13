# frozen_string_literal: true

module HwfHmrcApi
  module ConnectionAttributeValidation
    require_relative "hwf_hmrc_api_error"

    def validate_mandatory_attributes(connection_attributes)
      hmrc_secret_present?(connection_attributes[:hmrc_secret])
      totp_secret_present?(connection_attributes[:totp_secret])
      client_id_present?(connection_attributes[:client_id])
    end

    def hmrc_secret_present?(value)
      return true unless value.nil? || value.empty?

      raise HwfHmrcApiError.new("Connection attributes validation: HMRC secret is missing", :validation)
    end

    def totp_secret_present?(value)
      return true unless value.nil? || value.empty?

      raise HwfHmrcApiError.new("Connection attributes validation: TOTP secret is missing", :validation)
    end

    def client_id_present?(value)
      return true unless value.nil? || value.empty?

      raise HwfHmrcApiError.new("Connection attributes validation: CLIENT ID is missing", :validation)
    end

  end
end
