# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::IndividualIncome do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::IndividualIncome } }
  subject(:individual_income) { dummy_class }

  let(:matching_id) { "6789" }
  let(:from_date) { "2021-01-20" }
  let(:to_date) { "2021-02-20" }

  context "missing matching_id" do
    before { allow(dummy_class).to receive(:matching_id).and_return nil }

    it do
      expect do
        individual_income.paye(from_date, to_date)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end
  end

  context "matching_id present" do
    before { allow(dummy_class).to receive(:matching_id).and_return "1" }

    describe "Paye" do
      context "date present validation" do
        it do
          expect do
            individual_income.paye("", to_date)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromDate is missing")
        end

        it do
          expect do
            individual_income.paye(nil, to_date)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromDate is missing")
        end

        it do
          expect do
            individual_income.paye(from_date, "")
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToDate is missing")
        end

        it do
          expect do
            individual_income.paye(from_date, nil)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToDate is missing")
        end

        it do
          expect do
            individual_income.paye(123, to_date)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromDate is not a String")
        end
      end

      context "date format YYYY-MM-DD" do
        it do
          expect do
            individual_income.paye("21-01-2000", to_date)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromDate format is invalid")
        end

        it do
          expect do
            individual_income.paye(from_date, "21-01-2021")
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToDate format is invalid")
        end
      end
    end
  end
end
