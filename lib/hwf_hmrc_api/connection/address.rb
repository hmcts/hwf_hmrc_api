# frozen_string_literal: true

require "hwf_hmrc_api/connection/concerns/date_helper"

module HwfHmrcApi
  module Address
    include DateHelper

    # From Date format: YYYY-MM-DD
    # To Date format: YYYY-MM-DD
    def addresses(from_date, to_date)
      validate_match_id
      validate_dates(from_date, to_date)
      params = request_params(from_date, to_date)
      HwfHmrcApi::Endpoint.addresses(access_token, params)
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
