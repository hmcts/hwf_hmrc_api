# frozen_string_literal: true

RSpec.describe HwfHmrcApi::Endpoint do
  subject(:endoint) { HwfHmrcApi::Endpoint }


  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "4ece41402ecabdd91265f561baf602b8" }

  describe 'API calls' do
    context 'token' do
      let(:auth_token) {{
        "access_token": "QGbWG8KckncuwwD4uYXgWxF4HQvuPmrmUqKgkpQP",
        "token_type": "bearer",
        "expires_in": 14400,
        "scope": "hello"
      }}

      it "with invalid params and validation exception" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/oauth/token")
          .to_return(body: auth_token.to_json, status: 200)

        response = HwfHmrcApi::Endpoint.token(1,2).transform_keys {|key| key.to_sym }
        expect(response).to eq(auth_token)
      end

      it "with invalid params and validation exception" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/oauth/token")
          .to_return(body: {error: 'Error name', error_description: 'Error description'}.to_json,
            status: 401)

        expect { HwfHmrcApi::Endpoint.token(1,2) }.to raise_error(HwfHmrcApiError, "API call error: Error name: Error description")
      end
    end

    context 'match_user' do

      it "found a match" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
          .to_return(body: match_user_response.to_json, status: 200)

        response = HwfHmrcApi::Endpoint.match_user(1,2)
        expect(response).to eq({matching_id: 'e5c601b6-0aea-4023-9c3b-4fc421ab3d48' })
      end

      it "with invalid params and validation exception" do
        stub_request(:post, "https://test-api.service.hmrc.gov.uk/individuals/matching")
          .to_return(body: {code: "MATCHING_FAILED", message: "There is no match for the information provided"}.to_json,
                    status: 403)
        expect { HwfHmrcApi::Endpoint.match_user(1,2) }.to raise_error(HwfHmrcApiError, "API call error: MATCHING_FAILED: There is no match for the information provided")
      end
    end
  end

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

end
