# frozen_string_literal: true

require "hwf_hmrc_api/connection/concerns/date_helper"

module HwfHmrcApi
  module TaxCredit
    include DateHelper

    # From Date format: YYYY-MM-DD
    # To Date format: YYYY-MM-DD
    def child_tax_credits(from_date, to_date, correlation_id)
      validate_match_id
      validate_dates(from_date, to_date)
      params = request_params(from_date, to_date)
      HwfHmrcApi::Endpoint.child_tax_credits(header_info(correlation_id), params)
    end

    # From Date format: YYYY-MM-DD
    # To Date format: YYYY-MM-DD
    def working_tax_credits(from_date, to_date, correlation_id)
      validate_match_id
      validate_dates(from_date, to_date)
      params = request_params(from_date, to_date)
      HwfHmrcApi::Endpoint.working_tax_credits(header_info(correlation_id), params)
    end

    private

    def validate_match_id
      raise HwfHmrcApiError.new("Params validation: Mathching ID is missing", :standard_error) if matching_id.nil?
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
