# frozen_string_literal: true

module HwfHmrcApi
  module Employment
    # From Date format: YYYY-MM-DD
    # To Date format: YYYY-MM-DD
    def employments(from_date, to_date)
      validate_match_id
      validate_dates(from_date, to_date)
      params = request_params(from_date, to_date)
      HwfHmrcApi::Endpoint.employments_paye(access_token, params)
    end

    private

    def validate_match_id
      raise HwfHmrcApiError.new("Params validation: Mathching ID is missing", :standard_error) if matching_id.nil?
    end

    def validate_dates(from_date, to_date)
      raise_hwf_api_error("FromDate is not a String") unless date_type_valid?(from_date)
      raise_hwf_api_error("ToDate is not a String") unless date_type_valid?(to_date)
      raise_hwf_api_error("FromDate is missing") unless date_present?(from_date)
      raise_hwf_api_error("ToDate is missing") unless date_present?(to_date)
      raise_hwf_api_error("FromDate format is invalid") unless date_format_valid?(from_date)
      raise_hwf_api_error("ToDate format is invalid") unless date_format_valid?(to_date)
    end

    def date_type_valid?(value)
      return true if value.nil?

      value.is_a?(String)
    end

    def date_present?(value)
      return false if value.nil? || value.empty?

      true
    end

    def date_format_valid?(value)
      return true if value.match(/\d{4}-\d{2}-\d{2}/) && Date.strptime(value, "%Y-%m-%d")

      false
    rescue ArgumentError
      raise HwfHmrcApiError, "Attributes validation: Date format #{value} is invalid"
    end

    def date_out_of_range?(string)
      hundred_years_ago = Date.today.year - 100
      Date.parse(string) <= Date.parse("#{hundred_years_ago}-01-01")
    end

    def raise_hwf_api_error(message, prefix = "Attributes validation:")
      raise HwfHmrcApiError, "#{prefix} #{message}"
    end

    def request_params(from, to)
      {
        matching_id: matching_id,
        from: from,
        to: to
      }
    end
  end
end
