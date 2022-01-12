# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::Endpoint do
  subject(:endoint) { described_class }

  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "8ca019f0c4024233e746f92562d73a52" }
  let(:correlation_id) { "c93b5167-71d7-433a-b06f-08dc387203e4" }

  let(:header_info) do
    { access_token: access_token,
      correlation_id: correlation_id }
  end

  describe "API calls" do
    context "token" do
      let(:auth_token) do
        {
          "access_token": access_token,
          "token_type": "bearer",
          "expires_in": 14_400,
          "scope": "hello"
        }
      end

      it "with valid params and validation exception" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/oauth/token")
          .to_return(body: auth_token.to_json, status: 200)

        response = described_class.token(1, 2).transform_keys(&:to_sym)
        expect(response).to eq(auth_token)
      end

      context "generic 500 response" do
        it "without formatted json response" do
          stub_request(:post, "https://test-api.service.hmrc.gov.uk/oauth/token")
            .to_return(body: "Something went wrong", status: 500)
          expect do
            described_class.token(1, 2)
          end.to raise_error(HwfHmrcApiError, "783: unexpected token at 'Something went wrong'")
        end
      end

      context "token errors" do
        context "status_code 400" do
          let(:status_code) { 400 }
          it do
            VCR.use_cassette "hmrc_token_400" do
              expect do
                described_class.token(1, 2)
              end.to raise_error(HwfHmrcApiError, "API: invalid_request - client_secret is required")
            end
          end
        end

        context "status_code 401" do
          let(:status_code) { 401 }
          it do
            VCR.use_cassette "hmrc_token_401" do
              expect do
                described_class.token(1, 2)
              end.to raise_error(HwfHmrcApiError, "API: invalid_client - invalid client id or secret")
            end
          end
        end

        context "status_code 500" do
          let(:status_code) { 500 }
          it do
            VCR.use_cassette "hmrc_token_500" do
              expect do
                described_class.token(1, 2)
              end.to raise_error(HwfHmrcApiError, "API: server_error - something went wrong")
            end
          end
        end
      end
    end

    context "uuid" do
      it "generate new one if empty" do
        allow(SecureRandom).to receive(:uuid)
        VCR.use_cassette "match_user_success" do
          info_hash = { access_token: access_token }
          user_info = { "firstName": "Nell", "lastName": "Walker", "nino": "ZL262438D", "dateOfBirth": "1964-09-20" }
          described_class.match_user(info_hash, user_info)
          expect(SecureRandom).to have_received(:uuid)
        end
      end

      it "use one from params" do
        allow(SecureRandom).to receive(:uuid)
        VCR.use_cassette "match_user_success" do
          user_info = { "firstName": "Nell", "lastName": "Walker", "nino": "ZL262438D", "dateOfBirth": "1964-09-20" }
          described_class.match_user(header_info, user_info)
          expect(SecureRandom).not_to have_received(:uuid)
        end
      end
    end

    context "match_user" do
      it "found a match" do
        VCR.use_cassette "match_user_success" do
          user_info = { "firstName": "Nell", "lastName": "Walker", "nino": "ZL262438D", "dateOfBirth": "1964-09-20" }
          response = described_class.match_user(header_info, user_info)
          expect(response).to eq({ matching_id: "d7899dfd-99c1-44f4-b3c3-c7631d206245" })
        end
      end

      context "error response" do
        context "erorr code 403" do
          it do
            VCR.use_cassette "match_user_matching_failed" do
              user_info = { "firstName": "Nell", "lastName": "Walker", "nino": "ZL262438D",
                            "dateOfBirth": "1960-09-20" }
              expect do
                described_class.match_user(header_info, user_info)
              end.to raise_error(HwfHmrcApiError,
                                 "API: MATCHING_FAILED - There is no match for the information provided")
            end
          end
        end

        context "erorr code 400" do
          it do
            VCR.use_cassette "match_user_invalid_request" do
              user_info = { "firstName": "Nell" }
              expect do
                described_class.match_user(header_info, user_info)
              end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - nino is required")
            end
          end
        end

        context "erorr code 401 INVALID_CREDENTIALS" do
          it do
            VCR.use_cassette "hmrc_user_matching_invalid_token_error" do
              user_info = { "firstName": "Nell", "lastName": "Walker", "nino": "ZL262438D",
                            "dateOfBirth": "1960-09-20" }
              expect do
                described_class.match_user(header_info, user_info)
              end.to raise_error(HwfHmrcApiTokenError,
                                 "API: INVALID_CREDENTIALS - Invalid Authentication information provided")
            end
          end
        end
      end
    end

    context "generic 500 response" do
      it "without formatted json response" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
          .to_return(body: "Something went wrong", status: 500)
        expect do
          described_class.match_user(header_info, 2)
        end.to raise_error(HwfHmrcApiError, "783: unexpected token at 'Something went wrong'")
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  def match_user_response
    {
      "_links": {
        "individual": {
          "name": "GET",
          "href": "/individuals/matching/e5c601b6-0aea-4023-9c3b-4fc421ab3d48",
          "title": "Get a matched individual’s information"
        },
        "self": {
          "href": "/individuals/matching/"
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
