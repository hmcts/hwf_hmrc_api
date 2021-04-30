# frozen_string_literal: true

# /individuals/income/summary
# /individuals/income/interests-and-dividends
# /individuals/income/self-employments
# /individuals/income/uk-properties
# /individuals/income/foreign
# /individuals/income/paye

module HwfHmrcApi
  module IndividualIncome
    require_relative "hwf_hmrc_api_error"
    # YYYY-MM-DD  date format
    def paye(from_date, to_date)
      validate_match_id
      validate_dates(from_date, to_date)
    end

    private

    def validate_match_id
      raise HwfHmrcApiError.new("Params validation: Mathching ID is missing", :standard_error) if matching_id.nil?
    end

    def validate_dates(from_date, to_date)
      raise HwfHmrcApiError, "Attributes validation: FromDate is not a String" unless date_type_valid?(from_date)
      raise HwfHmrcApiError, "Attributes validation: ToDate is not a String" unless date_type_valid?(to_date)
      raise HwfHmrcApiError, "Attributes validation: FromDate is missing" unless date_present?(from_date)
      raise HwfHmrcApiError, "Attributes validation: ToDate is missing" unless date_present?(to_date)
      raise HwfHmrcApiError, "Attributes validation: FromDate format is invalid" unless date_format_valid?(from_date)
      raise HwfHmrcApiError, "Attributes validation: ToDate format is invalid" unless date_format_valid?(to_date)
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
  end
end
