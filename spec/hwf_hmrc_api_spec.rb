# frozen_string_literal: true

RSpec.describe HwfHmrcApi do
  it "has a version number" do
    expect(HwfHmrcApi::VERSION).not_to be nil
  end

  describe "load credentials" do
    let(:hmrc_secret) { "12345" }
    let(:totp_secret) { "base32secret3232" }
    let(:client_id) { "6789" }
    let(:connection_attributes) do
      {
        hmrc_secret: hmrc_secret,
        totp_secret: totp_secret,
        client_id: client_id
      }
    end

    context "values provided" do
      before do
        allow(HwfHmrcApi::Connection).to receive(:new).and_return "connection"
      end
      it {
        expect { described_class.new(connection_attributes) }.not_to raise_error
      }

      context "mandatory attributes" do
        it {
          expect do
            described_class.new(connection_attributes.merge(hmrc_secret: ""))
          end.to raise_error(HwfHmrcApiError,
                             "Connection attributes validation: HMRC secret is missing")
        }

        it {
          expect do
            described_class.new(connection_attributes.merge(totp_secret: ""))
          end.to raise_error(HwfHmrcApiError,
                             "Connection attributes validation: TOTP secret is missing")
        }

        it {
          expect do
            described_class.new(connection_attributes.merge(client_id: ""))
          end.to raise_error(HwfHmrcApiError,
                             "Connection attributes validation: CLIENT ID is missing")
        }
      end

      context "access_token and expires_in attributes" do
        let(:expires_in) { Time.now + 3600 }

        it "allows to pass auth token and expires_in time" do
          expect do
            described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
          end.not_to raise_error(HwfHmrcApiError)
        end

        context "expires in validation" do
          it "expires_in as valid string date" do
            expires_in = "2030-04-27 12:21:43"
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
            end.not_to raise_error(HwfHmrcApiError)
          end

          it "expires_in as valid string date in past" do
            expires_in = "2020-04-27 12:21:43"
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
            end.to raise_error(HwfHmrcApiError)
          end

          it "expires_in as invalid string date" do
            expires_in = "2021"
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN has invalid format")
          end

          it "expires_in as invalid string" do
            expires_in = "test"
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN has invalid format")
          end

          it "expires_in as Time now" do
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: Time.now + 100))
            end.not_to raise_error(HwfHmrcApiError)
          end

          it "expires_in as Time in past" do
            expires_in = Time.now - 3600
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: expires_in))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN is in past")
          end

          it "expires_in is integer number in past" do
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken",
                                                              expires_in: Time.now.to_i - 100))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN is in past")
          end

          it "expires_in is integer number in future" do
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken",
                                                              expires_in: Time.now.to_i + 100))
            end.not_to raise_error(HwfHmrcApiError)
          end

          it "expires_in is float number in past" do
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken",
                                                              expires_in: Time.now.to_f - 100))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN is in past")
          end

          it "expires_in is float number in future" do
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken",
                                                              expires_in: Time.now.to_f + 100))
            end.not_to raise_error(HwfHmrcApiError)
          end
        end

        context "validate presence of time when token present" do
          it {
            expect do
              described_class.new(connection_attributes.merge(access_token: "secrettoken", expires_in: ""))
            end.to raise_error(HwfHmrcApiError, "Connection attributes validation: EXPIRES IN is missing")
          }
        end
      end

      it "return connection instance" do
        connection = described_class.new(connection_attributes)
        expect(connection).to eql("connection")
      end
    end
  end
end
