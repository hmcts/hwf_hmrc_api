# frozen_string_literal: true

require "rotp"
require_relative "authentication"
require_relative "user_validation"

module HwfHmrcApi
  class Connection
    include UserValidation

    def initialize(connection_attributes)
      @authentication = HwfHmrcApi::Authentication.new(connection_attributes)
    end
    # Load token/store token / check for token and the expiry date - managed in token class
    # What to do here?
    # store ID references like match id
    # call specific endpoints via API class/interface
    # API class - calls the api/ parse response / checks for errors

    def match_user(user_params)
      validate_user_params(user_params)
      user_info = map_user_params(user_params)
      match_id = HwfHmrcApi::Endpoint.match_user(@authentication.access_token, user_info)
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
