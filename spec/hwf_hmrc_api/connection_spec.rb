# frozen_string_literal: true

require "timecop"

RSpec.describe HwfHmrcApi::Connection do
  subject(:connection) { described_class.new(connection_attributes) }
  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "d7070416e4e8e6dd8384573a24d2a1eb" }
  let(:connection_attributes) {{
     hmrc_secret: hmrc_secret,
     totp_secret: totp_secret,
     client_id: client_id
  }}

  before do
    authentication = instance_double("HwfHmrcApi::Authentication")
    allow(authentication).to receive(:access_token).and_return access_token
    allow(HwfHmrcApi::Authentication).to receive(:new).and_return authentication
  end

  describe "init" do
    it "load authentication" do
      subject
      expect(HwfHmrcApi::Authentication).to have_received(:new)
    end
  end

  describe "match user" do
    let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }
    let(:user_info) { { "firstName": "Tom", "lastName": "Jerry", "nino": "SN123456C", "dateOfBirth": "1950-05-09" } }

    it "with valid params" do
      expect(HwfHmrcApi::Endpoint).to receive(:match_user)
      subject.match_user(user_params)
    end

    it "with invalid params and validation exception" do
      expect { subject.match_user(user_params.merge(nino: '')) }.to raise_error
    end

    it "call endpoint with formatted params" do
      expect(HwfHmrcApi::Endpoint).to receive(:match_user).with(access_token, user_info)
      subject.match_user(user_params)
    end
  end

end
