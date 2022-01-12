# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::Employment do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::Employment } }
  subject(:employment) { dummy_class }

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

  let(:correlation_id) { "b77609d0-8a2a-0139-cebe-1e00e23ae066" }
  let(:header_info) do
    { access_token: access_token,
      correlation_id: correlation_id }
  end

  context "missing matching_id" do
    before { allow(dummy_class).to receive(:matching_id).and_return nil }

    it "Employments" do
      expect do
        employment.employments(from_date, to_date, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end
  end

  context "matching_id present" do
    before do
      allow(dummy_class).to receive(:matching_id).and_return matching_id
      allow(dummy_class).to receive(:access_token).and_return access_token
      allow(dummy_class).to receive(:header_info).and_return header_info
    end

    describe "Employments paye" do
      include_examples "Date validation", described_class, :employments

      context "call endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:employments_paye).and_return({})
          employment.employments(from_date, to_date, correlation_id)
          expect(HwfHmrcApi::Endpoint).to have_received(:employments_paye).with(header_info, request_params)
        end
      end
    end
  end
end
