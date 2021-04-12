# frozen_string_literal: true

require_relative "endpoint"

module HwfHmrcApi
  class Authentication
    # client_secret has to renew to ask for new token
    # Time + expires_at is for when the token should be re-newed
    # Parse the response and check for failed responses - this could be managed in
    # class that will handle the calls
    attr_reader :access_token

    def initialize(hmrc_secret, totp_secret, client_id)
      @totp_secret = totp_secret
      @hmrc_secret = hmrc_secret
      @client_id = client_id
    end

    def token
      get_token if @token.nil? || expired?
      access_token
    end

    def get_token
      @token = HwfHmrcApi::Endpoint.token(clien_secret, @client_id)
      set_expired_time
      load_access_token
    end

    def expired?
      # renew before it expires
      time_now = Time.now + 100
      @expires_in <= time_now
    end

    def renew; end

    private

    def set_expired_time
      @expires_in = Time.now + @token[:expires_in]
    end

    def clien_secret
      totp_code + @hmrc_secret
    end

    def totp_code
      totp_secret = @totp_secret
      totp = ROTP::TOTP.new(totp_secret, digits: 8, digest: "sha512")
      totp.now
    end

    def load_access_token
      @access_token = @token[:access_token]
    end

  end
end
