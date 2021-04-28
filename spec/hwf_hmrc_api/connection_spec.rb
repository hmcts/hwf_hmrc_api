# frozen_string_literal: true

require "timecop"

RSpec.describe HwfHmrcApi::Connection do
  subject(:connection) { described_class.new(connection_attributes) }
  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "d7070416e4e8e6dd8384573a24d2a1eb" }
  let(:connection_attributes) do
    {
      hmrc_secret: hmrc_secret,
      totp_secret: totp_secret,
      client_id: client_id
    }
  end

  let(:authentication) { instance_double("HwfHmrcApi::Authentication") }

  before do
    allow(authentication).to receive(:access_token).and_return access_token
    allow(HwfHmrcApi::Authentication).to receive(:new).and_return authentication
  end

  describe "init" do
    it "load authentication" do
      connection
      expect(HwfHmrcApi::Authentication).to have_received(:new)
    end
  end

  describe "match user" do
    let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }
    let(:user_info) { { "firstName": "Tom", "lastName": "Jerry", "nino": "SN123456C", "dateOfBirth": "1950-05-09" } }

    it "with valid params" do
      allow(HwfHmrcApi::Endpoint).to receive(:match_user)
      connection.match_user(user_params)
      expect(HwfHmrcApi::Endpoint).to have_received(:match_user)
    end

    it "with invalid params and validation exception" do
      expect do
        connection.match_user(user_params.merge(nino: ""))
      end.to raise_error(HwfHmrcApiError,
                         "User validation: NINO is missing")
    end

    it "call endpoint with formatted params" do
      allow(HwfHmrcApi::Endpoint).to receive(:match_user)
      connection.match_user(user_params)
      expect(HwfHmrcApi::Endpoint).to have_received(:match_user).with(access_token, user_info)
    end

    context "expired token" do
      it "re-new token" do
        VCR.use_cassette "hmrc_user_matching_invalid_token_error" do
          allow(authentication).to receive(:access_token).and_return(access_token, "new token")
          allow(authentication).to receive(:get_token)
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(access_token, user_info).and_call_original
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with("new token", user_info).and_return(true)
          connection.match_user(user_params)
          expect(authentication).to have_received(:get_token).once
        end
      end

      it "rerun the match request" do
        VCR.use_cassette "hmrc_user_matching_invalid_token_error" do
          allow(authentication).to receive(:access_token).and_return(access_token, "new token")
          allow(authentication).to receive(:get_token)
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(access_token, user_info).and_call_original
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with("new token", user_info).and_return(true)
          connection.match_user(user_params)
          expect(HwfHmrcApi::Endpoint).to have_received(:match_user).twice
        end
      end
    end
  end
end
