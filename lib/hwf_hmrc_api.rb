# frozen_string_literal: true

require "rotp"
require_relative "hwf_hmrc_api/version"
require_relative "hwf_hmrc_api/connection"

module HwfHmrcApi
  class << self
    def new(hmrc_secret, totp_secret, client_id)
      @hmrc_secret = hmrc_secret
      @totp_secret = totp_secret
      client_secret = totp_code + hmrc_secret

      HwfHmrcApi::Connection.new(client_secret, client_id)
    end

    private

    def totp_code
      totp_secret = @totp_secret
      totp = ROTP::TOTP.new(totp_secret, digits: 8, digest: "sha512")
      totp.now
    end
  end
end
