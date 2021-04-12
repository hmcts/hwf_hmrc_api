# frozen_string_literal: true

require "timecop"

RSpec.describe HwfHmrcApi::Authentication do
  subject(:application) { described_class.new(hmrc_secret, totp_secret, client_id) }
  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:auth_token) do
    { "access_token": "d7070416e4e8e6dd8384573a24d2a1eb",
      "scope": "read:individuals-matching-hmcts-c2",
      "expires_in": expires_in,
      "token_type": "bearer" }
  end
  let(:expires_in) { 14_400 }

  it "has a version number" do
    expect(HwfHmrcApi::VERSION).not_to be nil
  end

  describe "load credentials" do
    context "totp" do
      let(:totp) { instance_double(ROTP::TOTP) }
      before do
        allow(HwfHmrcApi::Endpoint).to receive(:token).and_return auth_token
        allow(ROTP::TOTP).to receive(:new).with(totp_secret, digits: 8, digest: "sha512").and_return totp
        allow(totp).to receive(:now).and_return "98765432"
      end

      it "generated TOTP code" do
        subject.token
        expect(totp).to have_received(:now)
      end

      it "passed TOTP code with secret to connection" do
        client_secret = "98765432#{hmrc_secret}"
        expect(HwfHmrcApi::Endpoint).to receive(:token).with(client_secret, client_id)
        subject.token
      end

      it "load stored token" do
        subject.token
        expect(HwfHmrcApi::Endpoint).not_to receive(:token)
        subject.token
      end

      it "load access token" do
        subject.token
        expect(subject.access_token).to eql("d7070416e4e8e6dd8384573a24d2a1eb")
      end

      it "token method returns auth_token too" do
        expect(subject.token).to eql("d7070416e4e8e6dd8384573a24d2a1eb")
      end

      context "expires time" do
        let(:expires_in) { 0 }
        it "load new token if old is expired" do
          subject.token
          expect(HwfHmrcApi::Endpoint).to receive(:token)
          subject.token
        end
      end

      context "set expires time according expire number from token" do
        let(:expires_in) { 400 }
        it "set expire time" do
          Timecop.freeze(Time.now) do
            subject.token

            expect(subject.expired?).to be_falsey
          end
        end
      end
      context "set expires time according expire number from token" do
        let(:expires_in) { 100 }
        it "set expire time" do
          Timecop.freeze(Time.now) do
            subject.token

            expect(subject.expired?).to be_truthy
          end
        end
      end
    end
  end
end
