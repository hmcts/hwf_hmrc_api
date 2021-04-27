# frozen_string_literal: true

require "timecop"

RSpec.describe HwfHmrcApi::Authentication do
  subject(:application) { described_class.new(connection_attributes) }
  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:auth_token) do
    { "access_token": access_token,
      "scope": "read:individuals-matching-hmcts-c2",
      "expires_in": expires_in,
      "token_type": "bearer" }
  end
  let(:expires_in) { 14_400 }
  let(:access_token) { "d7070416e4e8e6dd8384573a24d2a1eb" }

  it "has a version number" do
    expect(HwfHmrcApi::VERSION).not_to be nil
  end

  describe "load credentials" do
    let(:connection_attributes) do
      {
        hmrc_secret: hmrc_secret,
        totp_secret: totp_secret,
        client_id: client_id
      }
    end

    context "totp" do
      let(:totp) { instance_double(ROTP::TOTP) }
      before do
        allow(HwfHmrcApi::Endpoint).to receive(:token).and_return auth_token
        allow(ROTP::TOTP).to receive(:new).with(totp_secret, digits: 8, digest: "sha512").and_return totp
        allow(totp).to receive(:now).and_return "98765432"
      end

      it "generated TOTP code" do
        application.token
        expect(totp).to have_received(:now)
      end

      it "passed TOTP code with secret to connection" do
        client_secret = "98765432#{hmrc_secret}"
        application.token
        expect(HwfHmrcApi::Endpoint).to have_received(:token).with(client_secret, client_id)
      end

      it "load stored token" do
        application.token
        application.token
        expect(HwfHmrcApi::Endpoint).to have_received(:token).once
      end

      it "load access token" do
        application.token
        expect(application.access_token).to eql("d7070416e4e8e6dd8384573a24d2a1eb")
      end

      it "token method returns auth_token too" do
        expect(application.token).to eql("d7070416e4e8e6dd8384573a24d2a1eb")
      end

      context "expires time" do
        let(:expires_in) { 0 }
        it "load new token if old is expired" do
          application.token
          expect(HwfHmrcApi::Endpoint).to have_received(:token).twice
        end
      end

      context "not expired when expires_in is more then 100s in future" do
        let(:expires_in) { 400 }
        it "set expire time" do
          Timecop.freeze(Time.now) do
            application.token
            expect(application.expired?).to be_falsey
          end
        end
      end

      context "expired when expires_in is less or eql 100s in future" do
        let(:expires_in) { 100 }
        it "set expire time" do
          Timecop.freeze(Time.now) do
            application.token
            expect(application.expired?).to be_truthy
          end
        end
      end
    end
  end

  context "access_token provided in params" do
    let(:connection_attributes) do
      {
        hmrc_secret: hmrc_secret,
        totp_secret: totp_secret,
        client_id: client_id,
        access_token: access_token,
        expires_in: Time.now + 1000
      }
    end

    it "doesn't load new token" do
      allow(HwfHmrcApi::Endpoint).to receive(:token)
      application
      expect(HwfHmrcApi::Endpoint).not_to have_received(:token)
    end

    it "stores token in access_token value" do
      expect(application.access_token).to eql(access_token)
    end

    it "stores expires_in in a value" do
      expect(application.expires_in).to eql(connection_attributes[:expires_in])
    end
  end
end
