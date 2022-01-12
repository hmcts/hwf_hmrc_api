# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::Endpoint::Employment do
  subject(:endpoint) { HwfHmrcApi::Endpoint }

  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "58f7c026b99895d007e577dbcd481713" }
  let(:matching_id) { "0f44104e-7985-41f5-9660-ad9d02cffdb6" }
  let(:correlation_id) { "c93b5167-71d7-433a-b06f-08dc387203e4" }

  let(:header_info) do
    { access_token: access_token,
      correlation_id: correlation_id }
  end

  describe "API calls" do
    context "Employment paye" do
      it "found a record" do
        VCR.use_cassette "employment_paye_success" do
          request_params = { matching_id: matching_id, from: "2019-01-01",
                             to: "2019-03-31" }
          response = endpoint.employments_paye(header_info, request_params)
          expect(response[0]["employer"]).to have_key("name")
        end
      end

      it "no record found" do
        VCR.use_cassette "employment_paye_success_empty" do
          request_params = { matching_id: matching_id, from: "2019-04-02",
                             to: "2019-04-28" }
          response = endpoint.employments_paye(header_info, request_params)
          expect(response).to eq([])
        end
      end

      it "invalid request" do
        VCR.use_cassette "employment_paye_400" do
          request_params = { matching_id: matching_id, from: "",
                             to: "2019-04-28" }
          expect do
            endpoint.employments_paye(header_info, request_params)
          end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromDate: invalid date format")
        end
      end

      it "not found" do
        VCR.use_cassette "employment_paye_404" do
          request_params = { matching_id: "#{matching_id}3", from: "2019-04-02",
                             to: "2019-04-28" }
          expect do
            endpoint.employments_paye(header_info, request_params)
          end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
        end
      end
    end
  end
end
