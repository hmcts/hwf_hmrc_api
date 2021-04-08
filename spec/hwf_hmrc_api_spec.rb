# frozen_string_literal: true

RSpec.describe HwfHmrcApi do
  it "has a version number" do
    expect(HwfHmrcApi::VERSION).not_to be nil
  end

  describe "load credentials" do
    let(:hmrc_secret) { "12345" }
    let(:totp_secret) { "base32secret3232" }
    let(:client_id) { "6789" }

    context "values provided" do
      it "needs 3 keys" do
        expect { HwfHmrcApi.new(hmrc_secret, totp_secret, client_id) }.not_to raise_error
      end

      it "return connection instance" do
        connection = HwfHmrcApi.new(hmrc_secret, totp_secret, client_id)
        expect(connection).to be_a_kind_of(HwfHmrcApi::Connection)
      end

      context "totp" do
        let(:totp) { instance_double(ROTP::TOTP) }
        before do
          allow(ROTP::TOTP).to receive(:new).with(totp_secret, digits: 8, digest: "sha512").and_return totp
          allow(totp).to receive(:now).and_return "98765432"
        end

        it "generated TOTP code" do
          HwfHmrcApi.new(hmrc_secret, totp_secret, client_id)
          expect(totp).to have_received(:now)
        end

        it "passed TOTP code with secret to connection" do
          client_secret = "98765432#{hmrc_secret}"
          expect(HwfHmrcApi::Connection).to receive(:new).with(client_secret, client_id)
          HwfHmrcApi.new(hmrc_secret, totp_secret, client_id)
        end
      end
    end
  end
end
