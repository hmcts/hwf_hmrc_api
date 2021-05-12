# frozen_string_literal: true

module HwfHmrcApi
  module IndividualIncome
    # From Date format: YYYY-MM-DD
    # To Date format: YYYY-MM-DD
    def paye(from_date, to_date)
      validate_match_id
      validate_dates(from_date, to_date)
      params = request_params(from_date, to_date)
      HwfHmrcApi::Endpoint.income_paye(access_token, params)
    end

    # From Tax Year format: YYYY-YY
    # To Tax Year format: YYYY-YY
    def sa_summary(from_tax_year, to_tax_year)
      sa_income_endpoint(:income_summary, from_tax_year, to_tax_year)
    end

    # From Tax Year format: YYYY-YY
    # To Tax Year format: YYYY-YY
    def sa_interest_dividends(from_tax_year, to_tax_year)
      sa_income_endpoint(:income_interest_dividends, from_tax_year, to_tax_year)
    end

    # From Tax Year format: YYYY-YY
    # To Tax Year format: YYYY-YY
    def sa_self_employments(from_tax_year, to_tax_year)
      sa_income_endpoint(:income_self_employments, from_tax_year, to_tax_year)
    end

    # From Tax Year format: YYYY-YY
    # To Tax Year format: YYYY-YY
    def sa_uk_properties(from_tax_year, to_tax_year)
      sa_income_endpoint(:income_uk_properties, from_tax_year, to_tax_year)
    end

    # From Tax Year format: YYYY-YY
    # To Tax Year format: YYYY-YY
    def sa_foreign(from_tax_year, to_tax_year)
      sa_income_endpoint(:income_foreign, from_tax_year, to_tax_year)
    end

    private

    def sa_income_endpoint(method_name, from_tax_year, to_tax_year)
      validate_match_id
      validate_tax_years(from_tax_year, to_tax_year)
      params = request_params(from_tax_year, to_tax_year)

      HwfHmrcApi::Endpoint.send(method_name, access_token, params)
    end

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

    def validate_tax_years(from_tax_year, to_tax_year)
      raise_hwf_api_error("FromTaxYear is not a String") unless date_type_valid?(from_tax_year)
      raise_hwf_api_error("ToTaxYear is not a String") unless date_type_valid?(to_tax_year)
      raise_hwf_api_error("FromTaxYear is missing") unless date_present?(from_tax_year)
      raise_hwf_api_error("ToTaxYear is missing") unless date_present?(to_tax_year)
      raise_hwf_api_error("FromTaxYear format is invalid") unless tax_year_format_valid?(from_tax_year)
      raise_hwf_api_error("ToTaxYear format is invalid") unless tax_year_format_valid?(to_tax_year)
      raise_hwf_api_error("FromTaxYear year is before ToTaxYear") unless tax_years_in_order?(from_tax_year, to_tax_year)
    end

    def raise_hwf_api_error(message, prefix = "Attributes validation:")
      raise HwfHmrcApiError, "#{prefix} #{message}"
    end

    def tax_year_format_valid?(value)
      return true if value.match(/\d{4}-\d{2}/) && incremental_year(value)

      false
    rescue ArgumentError
      raise HwfHmrcApiError, "Attributes validation: Date format #{value} is invalid"
    end

    def incremental_year(value)
      years = value.split("-")
      first = years[0][2..3].to_i
      second = years[1].to_i
      first + 1 == second
    end

    def tax_years_in_order?(from, to)
      first = from.split("-")[0].to_i
      second = to.split("-")[0].to_i
      first <= second
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
