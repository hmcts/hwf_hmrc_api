# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::TaxCredit do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::TaxCredit } }
  subject(:tax_credit) { dummy_class }

  let(:matching_id) { "6789" }
  let(:from_date) { "2021-01-20" }
  let(:to_date) { "2021-02-20" }
  let(:access_token) { "0f3adcfc0e6f5ace9102af880cedd279" }

  let(:tax_request_params) do
    {
      matching_id: matching_id,
      from: from_date,
      to: to_date
    }
  end

  context "missing matching_id" do
    before { allow(dummy_class).to receive(:matching_id).and_return nil }

    it "Child" do
      expect do
        tax_credit.child_tax_credits(from_date, to_date)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Work" do
      expect do
        tax_credit.working_tax_credits("2018-19", "2019-20")
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end
  end

  context "matching_id present" do
    before do
      allow(dummy_class).to receive(:matching_id).and_return matching_id
      allow(dummy_class).to receive(:access_token).and_return access_token
    end

    describe "Child" do
      include_examples "Date validation", described_class, :child_tax_credits

      context "call endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:child_tax_credits).and_return({})
          tax_credit.child_tax_credits(from_date, to_date)
          expect(HwfHmrcApi::Endpoint).to have_received(:child_tax_credits).with(access_token, tax_request_params)
        end
      end
    end

    describe "Work" do
      include_examples "Date validation", described_class, :working_tax_credits

      context "call endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:working_tax_credits).and_return({})
          tax_credit.working_tax_credits(from_date, to_date)
          expect(HwfHmrcApi::Endpoint).to have_received(:working_tax_credits).with(access_token, tax_request_params)
        end
      end
    end
  end
end
