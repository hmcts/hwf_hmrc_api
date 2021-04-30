# frozen_string_literal: true

require "rotp"
require_relative "authentication"
require_relative "user_validation"
require_relative "individual_income"

module HwfHmrcApi
  class Connection
    include UserValidation
    include IndividualIncome
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
