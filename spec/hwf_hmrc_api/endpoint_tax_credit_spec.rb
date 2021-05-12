# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::EndpointTaxCredit do
  subject(:endpoint) { HwfHmrcApi::Endpoint }

  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "6f9d12d8c28da016ad6d26296c900087" }
  let(:matching_id) { "198247ac-7325-4233-ae65-9bd548658310" }

  describe "API calls" do
    context "Child Tax credit" do
      it "found a record" do
        VCR.use_cassette "child_tax_credit_success" do
          request_params = { matching_id: matching_id, from: "2018-02-02",
                             to: "2018-04-01" }
          response = endpoint.child_tax_credits(access_token, request_params)
          expect(response[0]["awards"][0]).to have_key("childTaxCredit")
        end
      end

      it "no record found" do
        VCR.use_cassette "child_tax_credit_success_empty" do
          request_params = { matching_id: matching_id, from: "2019-04-02",
                             to: "2019-04-28" }
          response = endpoint.child_tax_credits(access_token, request_params)
          expect(response).to eq([])
        end
      end

      it "invalid request" do
        VCR.use_cassette "child_tax_credit_400" do
          request_params = { matching_id: matching_id, from: "",
                             to: "2019-04-28" }
          expect do
            endpoint.child_tax_credits(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromDate: invalid date format")
        end
      end

      it "not found" do
        VCR.use_cassette "child_tax_credit_404" do
          request_params = { matching_id: "#{matching_id}3", from: "2019-04-02",
                             to: "2019-04-28" }
          expect do
            endpoint.child_tax_credits(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
        end
      end
    end

    context "Working Tax credit" do
      it "found a record" do
        VCR.use_cassette "work_tax_credit_success" do
          request_params = { matching_id: matching_id, from: "2019-02-02",
                             to: "2019-04-01" }
          response = endpoint.working_tax_credits(access_token, request_params)
          expect(response[0]["awards"][0]).to have_key("workingTaxCredit")
        end
      end

      it "no record found" do
        VCR.use_cassette "work_tax_credit_success_empty" do
          request_params = { matching_id: matching_id, from: "2019-04-02",
                             to: "2019-04-28" }
          response = endpoint.working_tax_credits(access_token, request_params)
          expect(response).to eq([])
        end
      end

      it "invalid request" do
        VCR.use_cassette "work_tax_credit_400" do
          request_params = { matching_id: matching_id, from: "",
                             to: "2019-04-28" }
          expect do
            endpoint.working_tax_credits(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromDate: invalid date format")
        end
      end

      it "not found" do
        VCR.use_cassette "work_tax_credit_404" do
          request_params = { matching_id: "#{matching_id}3", from: "2019-04-02",
                             to: "2019-04-28" }
          expect do
            endpoint.working_tax_credits(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
        end
      end
    end
  end
end