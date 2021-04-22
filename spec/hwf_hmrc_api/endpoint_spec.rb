# frozen_string_literal: true

RSpec.describe HwfHmrcApi::Endpoint do
  subject(:endoint) { described_class }

  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "4ece41402ecabdd91265f561baf602b8" }

  describe "API calls" do
    context "token" do
      let(:auth_token) do
        {
          "access_token": "QGbWG8KckncuwwD4uYXgWxF4HQvuPmrmUqKgkpQP",
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
        before do
          stub_request(:post, "https://test-api.service.hmrc.gov.uk/oauth/token")
            .to_return(body: { error: "Error name", error_description: "Error description" }.to_json,
                       status: status_code)
        end

        context "status_code 400" do
          let(:status_code) { 400 }
          it do
            expect do
              described_class.token(1, 2)
            end.to raise_error(HwfHmrcApiError, "API: Error name - Error description")
          end
        end

        context "status_code 401" do
          let(:status_code) { 401 }
          it do
            expect do
              described_class.token(1, 2)
            end.to raise_error(HwfHmrcApiError, "API: Error name - Error description")
          end
        end

        context "status_code 500" do
          let(:status_code) { 500 }
          it do
            expect do
              described_class.token(1, 2)
            end.to raise_error(HwfHmrcApiError, "API: Error name - Error description")
          end
        end
      end
    end

    context "match_user" do
      it "found a match" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
          .to_return(body: match_user_response.to_json, status: 200)

        response = described_class.match_user(1, 2)
        expect(response).to eq({ matching_id: "e5c601b6-0aea-4023-9c3b-4fc421ab3d48" })
      end

      context "error response" do
        before do
          stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
            .to_return(body: { code: hash_code,
                               message: "There is no match for the information provided" }.to_json,
                       status: status_code)
        end

        context "erorr code 403" do
          let(:status_code) { 403 }
          let(:hash_code) { "MATCHING_FAILED" }
          it do
            expect do
              described_class.match_user(1, 2)
            end.to raise_error(HwfHmrcApiError, "API: MATCHING_FAILED - There is no match for the information provided")
          end
        end

        context "erorr code 400" do
          let(:status_code) { 400 }
          let(:hash_code) { "INVALID_REQUEST" }

          it do
            expect do
              described_class.match_user(1, 2)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - There is no match for the information provided")
          end
        end
      end
    end

    context "generic 500 response" do
      it "without formatted json response" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
          .to_return(body: "Something went wrong", status: 500)
        expect do
          described_class.match_user(1, 2)
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
