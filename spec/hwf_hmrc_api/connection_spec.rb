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
  let(:correlation_id) { "b77609d0-8a2a-0139-cebe-1e00e23ae066" }
  let(:header_info) do
    { access_token: access_token,
      correlation_id: correlation_id }
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

  describe "access_token" do
    it { expect(connection.access_token).to eql(access_token) }
  end

  describe "match user" do
    let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }
    let(:user_info) { { "firstName": "Tom", "lastName": "Jerry", "nino": "SN123456C", "dateOfBirth": "1950-05-09" } }

    it "with valid params" do
      allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
      connection.match_user(user_params, correlation_id)
      expect(HwfHmrcApi::Endpoint).to have_received(:match_user)
    end

    it "with invalid params and validation exception" do
      expect do
        connection.match_user(user_params.merge(nino: ""), correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "User validation: NINO is missing")
    end

    it "call endpoint with formatted params" do
      allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
      connection.match_user(user_params, correlation_id)
      expect(HwfHmrcApi::Endpoint).to have_received(:match_user).with(header_info, user_info)
    end

    it "store matching_id to attribute" do
      allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
      connection.match_user(user_params, correlation_id)
      expect(connection.matching_id).to eql("id")
    end

    context "expired token" do
      it "re-new token" do
        VCR.use_cassette "hmrc_user_matching_invalid_token_error" do
          allow(authentication).to receive(:access_token).and_return(access_token, "new token")
          allow(authentication).to receive(:get_token)
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(header_info, user_info).and_call_original
          new_header_info = { access_token: "new token", correlation_id: correlation_id }
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(new_header_info,
                                                                   user_info).and_return({ matching_id: "id" })
          connection.match_user(user_params, correlation_id)
          expect(authentication).to have_received(:get_token).once
        end
      end

      it "rerun the match request" do
        VCR.use_cassette "hmrc_user_matching_invalid_token_error" do
          allow(authentication).to receive(:access_token).and_return(access_token, "new token")
          allow(authentication).to receive(:get_token)
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(header_info, user_info).and_call_original
          new_header_info = { access_token: "new token", correlation_id: correlation_id }
          allow(HwfHmrcApi::Endpoint).to receive(:match_user).with(new_header_info,
                                                                   user_info).and_return({ matching_id: "id" })
          connection.match_user(user_params, correlation_id)
          expect(HwfHmrcApi::Endpoint).to have_received(:match_user).twice
        end
      end
    end
  end

  describe "Individual income Paye" do
    let(:from_date) { "2021-01-20" }
    let(:to_date) { "2021-02-20" }

    context "missing matching_id" do
      it do
        expect do
          connection.paye(from_date, to_date, correlation_id)
        end.to raise_error(HwfHmrcApiError,
                           "Params validation: Mathching ID is missing")
      end
    end

    context "matching_id present" do
      let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }

      it do
        allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
        allow(HwfHmrcApi::Endpoint).to receive(:income_paye).and_return({})
        connection.match_user(user_params, correlation_id)

        expect do
          connection.paye(from_date, to_date, correlation_id)
        end.not_to raise_error
      end
    end
  end

  describe "Tax credits" do
    let(:from_date) { "2021-01-20" }
    let(:to_date) { "2021-02-20" }

    context "missing matching_id" do
      it do
        expect do
          connection.child_tax_credits(from_date, to_date, correlation_id)
        end.to raise_error(HwfHmrcApiError,
                           "Params validation: Mathching ID is missing")
      end
    end

    context "matching_id present" do
      let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }

      it do
        allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
        allow(HwfHmrcApi::Endpoint).to receive(:child_tax_credits).and_return({})
        connection.match_user(user_params, correlation_id)

        expect do
          connection.child_tax_credits(from_date, to_date, correlation_id)
        end.not_to raise_error
      end
    end
  end

  describe "Employment" do
    let(:from_date) { "2021-01-20" }
    let(:to_date) { "2021-02-20" }

    context "missing matching_id" do
      it do
        expect do
          connection.employments(from_date, to_date, correlation_id)
        end.to raise_error(HwfHmrcApiError,
                           "Params validation: Mathching ID is missing")
      end
    end

    context "matching_id present" do
      let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }

      it do
        allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
        allow(HwfHmrcApi::Endpoint).to receive(:employments_paye).and_return({})
        connection.match_user(user_params, correlation_id)

        expect do
          connection.employments(from_date, to_date, correlation_id)
        end.not_to raise_error
      end
    end
  end

  describe "Address" do
    let(:from_date) { "2021-01-20" }
    let(:to_date) { "2021-02-20" }

    context "missing matching_id" do
      it do
        expect do
          connection.addresses(from_date, to_date, correlation_id)
        end.to raise_error(HwfHmrcApiError,
                           "Params validation: Mathching ID is missing")
      end
    end

    context "matching_id present" do
      let(:user_params) { { first_name: "Tom", last_name: "Jerry", nino: "SN123456C", dob: "1950-05-09" } }

      it do
        allow(HwfHmrcApi::Endpoint).to receive(:match_user).and_return({ matching_id: "id" })
        allow(HwfHmrcApi::Endpoint).to receive(:addresses).and_return({})
        connection.match_user(user_params, correlation_id)

        expect do
          connection.addresses(from_date, to_date, correlation_id)
        end.not_to raise_error
      end
    end
  end
end
