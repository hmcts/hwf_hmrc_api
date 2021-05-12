# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::Address do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::Address } }
  subject(:address) { dummy_class }

  let(:matching_id) { "6789" }
  let(:from_date) { "2021-01-20" }
  let(:to_date) { "2021-02-20" }
  let(:access_token) { "0f3adcfc0e6f5ace9102af880cedd279" }

  let(:request_params) do
    {
      matching_id: matching_id,
      from: from_date,
      to: to_date
    }
  end

  context "missing matching_id" do
    before { allow(dummy_class).to receive(:matching_id).and_return nil }

    it "addresses" do
      expect do
        address.addresses(from_date, to_date)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end
  end

  context "matching_id present" do
    before do
      allow(dummy_class).to receive(:matching_id).and_return matching_id
      allow(dummy_class).to receive(:access_token).and_return access_token
    end

    describe "addresses" do
      include_examples "Date validation", described_class, :addresses

      context "call endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:addresses).and_return({})
          address.addresses(from_date, to_date)
          expect(HwfHmrcApi::Endpoint).to have_received(:addresses).with(access_token, request_params)
        end
      end
    end
  end
end
