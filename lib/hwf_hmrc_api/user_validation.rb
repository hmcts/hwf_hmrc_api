# frozen_string_literal: true

module HwfHmrcApi
  module UserValidation
    require_relative "hwf_hmrc_api_error"

    def user_valid?(user_params)
      dob_valid?(user_params[:dob])
      nino_present?(user_params[:nino])
      last_name_present?(user_params[:last_name])
      fist_name_present?(user_params[:first_name])
    end

    def dob_valid?(dob)
      if dob.nil? || dob.empty?
        raise HwfHmrcApiError.new("User validation: DOB is missing", :validation)
      elsif invalid_date?(dob)
        raise HwfHmrcApiError.new("User validation: DOB has wrong format", :validation)
      elsif date_out_of_range?(dob)
        raise HwfHmrcApiError.new("User validation: DOB is out of range", :validation)
      end

      true
    end

    def nino_present?(nino)
      return true unless nino.nil? || nino.empty?

      raise HwfHmrcApiError.new("User validation: NINO is missing", :validation)
    end

    def fist_name_present?(first_name)
      return true unless first_name.nil? || first_name.empty?

      raise HwfHmrcApiError.new("User validation: First name is missing", :validation)
    end

    def last_name_present?(last_name)
      return true unless last_name.nil? || last_name.empty?

      raise HwfHmrcApiError.new("User validation: Last name is missing", :validation)
    end

    private

    def invalid_date?(string)
      !(string.match(/\d{4}-\d{2}-\d{2}/) && Date.strptime(string, "%Y-%m-%d"))
    rescue ArgumentError
      true
    end

    def date_out_of_range?(string)
      hundred_years_ago = Date.today.year - 100
      Date.parse(string) <= Date.parse("#{hundred_years_ago}-01-01")
    end
  end
end
