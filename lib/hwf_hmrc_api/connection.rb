# frozen_string_literal: true

require "rotp"
require_relative "authentication"
require_relative "user_validation"
require "hwf_hmrc_api/hwf_hmrc_api_error"
require "hwf_hmrc_api/connection/individual_income"
require "hwf_hmrc_api/connection/tax_credit"
require "hwf_hmrc_api/connection/employment"
require "hwf_hmrc_api/connection/address"

# Connection methods
# IMPORTANT: To be able to get information about user you need to call match_user method first
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: match_user(user_info_hash)
#
# Method attributes example:
# { first_name: "Nell",
#   last_name: = "Walker",
#   nino: "ZL262438D",
#   dob: "1964-09-20" }
#
# Returns matching_id
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: paye(from_date, to_date)
#
# Method attributes example:
# from_date format: YYYY-MM-DD
# to_date format: YYYY-MM-DD
#
# Returns Hash: {"income"=> [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-paye-income-history_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: sa_summary(from_date, to_date)
#
# Method attributes example:
# from_tax_year format: YYYY-YY
# to_tax_year format: YYYY-YY
#
# Returns Hash: {"taxReturns" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-self-assessment-tax-returns-summary_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: sa_interest_dividends(from_date, to_date)
#
# Method attributes example:
# from_tax_year format: YYYY-YY
# to_tax_year format: YYYY-YY
#
# Returns Hash: {"taxReturns" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-interest-and-dividends-income-data-from-self-assessment_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: sa_self_employments(from_date, to_date)
#
# Method attributes example:
# from_tax_year format: YYYY-YY
# to_tax_year format: YYYY-YY
#
# Returns Hash: {"taxReturns" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-selfemployments-income-data-from-self-assessment_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: sa_uk_properties(from_date, to_date)
#
# Method attributes example:
# from_tax_year format: YYYY-YY
# to_tax_year format: YYYY-YY
#
# Returns Hash: {"taxReturns" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-uk-properties-income-data-from-self-assessment_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: sa_foreign(from_date, to_date)
#
# Method attributes example:
# from_tax_year format: YYYY-YY
# to_tax_year format: YYYY-YY
#
# Returns Hash: {"taxReturns" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-income-api/2.0#_get-foreign-income-data-from-self-assessment_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: child_tax_credits(from_date, to_date)
#
# Method attributes example:
# from_date format: YYYY-MM-DD
# to_date format: YYYY-MM-DD
#
# Returns Hash: {"applications" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-benefits-and-credits-api/1.0#_get-child-tax-credit-data_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: working_tax_credits(from_date, to_date)
#
# Method attributes example:
# from_date format: YYYY-MM-DD
# to_date format: YYYY-MM-DD
#
# Returns Hash: {"applications" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-benefits-and-credits-api/1.0#_get-working-tax-credit-data_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: employments(from_date, to_date)
#
# Method attributes example:
# from_date format: YYYY-MM-DD
# to_date format: YYYY-MM-DD
#
# Returns Hash: {"employments" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-employments-api/2.0#_get-employment-details_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #
# Method name: addresses(from_date, to_date)
#
# Method attributes example:
# from_date format: YYYY-MM-DD
# to_date format: YYYY-MM-DD
#
# Returns Hash: {"residences" => [...]}
#
# more info: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/individuals-details-api/1.0#_get-address-details_get_accordion
#
# # # # # # # # # # # # # # # # # # # # # # # #

module HwfHmrcApi
  class Connection
    include UserValidation
    include IndividualIncome
    include TaxCredit
    include Employment
    include Address

    attr_reader :matching_id, :authentication

    def initialize(connection_attributes)
      @authentication = HwfHmrcApi::Authentication.new(connection_attributes)
    end

    def match_user(user_params)
      validate_user_params(user_params)
      user_info = map_user_params(user_params)
      response = HwfHmrcApi::Endpoint.match_user(@authentication.access_token, user_info)
      @matching_id = response[:matching_id]
    rescue HwfHmrcApiTokenError
      @authentication.get_token
      match_user(user_params)
    end

    def access_token
      @authentication.access_token
    end

    private

    def validate_user_params(user_params)
      # raises an exception when not valid
      user_valid?(user_params)
    end

    def map_user_params(user_params)
      { "firstName": user_params[:first_name],
        "lastName": user_params[:last_name],
        "nino": user_params[:nino],
        "dateOfBirth": user_params[:dob] }
    end
  end
end
