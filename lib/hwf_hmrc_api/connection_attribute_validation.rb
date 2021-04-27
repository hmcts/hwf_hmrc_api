# frozen_string_literal: true

module HwfHmrcApi
  module ConnectionAttributeValidation
    require_relative "hwf_hmrc_api_error"

    def validate_mandatory_attributes(connection_attributes)
      hmrc_secret_present?(connection_attributes[:hmrc_secret])
      totp_secret_present?(connection_attributes[:totp_secret])
      client_id_present?(connection_attributes[:client_id])
      expires_in_valid?(connection_attributes[:expires_in]) if connection_attributes[:access_token]
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

    def expires_in_valid?(value)
      expires_in_blank?(value)
      validate_date_format(value)
      true
    rescue ArgumentError
      false
    end

    private

    def expires_in_blank?(value)
      return unless value.nil? || (value.is_a?(String) && value.empty?)

      raise HwfHmrcApiError.new("Connection attributes validation: EXPIRES IN is missing",
                                :validation)
    end

    def validate_date_format(value)
      case value
      when String
        string_date_validation(value)
      when Time, Integer, Float
        if Time.at(value) < Time.now
          raise HwfHmrcApiError.new("Connection attributes validation: EXPIRES IN is in past",
                                    :validation)
        end
      end
    end

    def string_date_validation(value)
      if DateTime.parse(value).to_time < Time.now
        raise HwfHmrcApiError.new("Connection attributes validation: EXPIRES IN is in past",
                                  :validation)
      end
    rescue Date::Error
      raise HwfHmrcApiError.new("Connection attributes validation: EXPIRES IN has invalid format", :validation)
    end
  end
end
