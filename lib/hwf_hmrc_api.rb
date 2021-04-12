# frozen_string_literal: true

require_relative "hwf_hmrc_api/version"
require_relative "hwf_hmrc_api/connection"

module HwfHmrcApi
  class << self
    def new(hmrc_secret, totp_secret, client_id)
      HwfHmrcApi::Connection.new(hmrc_secret, totp_secret, client_id)
    end
  end
end
