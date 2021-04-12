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
      it {
        expect { HwfHmrcApi.new(hmrc_secret, totp_secret, client_id) }.not_to raise_error
      }
      it {
        expect { HwfHmrcApi.new(hmrc_secret, totp_secret) }.to raise_error
      }

      it "return connection instance" do
        connection = HwfHmrcApi.new(hmrc_secret, totp_secret, client_id)
        expect(connection).to be_a_kind_of(HwfHmrcApi::Connection)
      end
    end
  end
end
