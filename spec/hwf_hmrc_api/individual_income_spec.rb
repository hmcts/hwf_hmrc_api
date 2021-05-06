# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::IndividualIncome do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::IndividualIncome } }
  subject(:individual_income) { dummy_class }

  let(:matching_id) { "6789" }
  let(:from_date) { "2021-01-20" }
  let(:to_date) { "2021-02-20" }
  let(:access_token) { "0f3adcfc0e6f5ace9102af880cedd279" }

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
    before do
      allow(dummy_class).to receive(:matching_id).and_return matching_id
      allow(dummy_class).to receive(:access_token).and_return access_token
    end

    describe "Paye" do
      let(:paye_request_params) do
        {
          matching_id: matching_id,
          from: from_date,
          to: to_date
        }
      end
      context "call endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:income_paye).and_return({})
          individual_income.paye(from_date, to_date)
          expect(HwfHmrcApi::Endpoint).to have_received(:income_paye).with(access_token, paye_request_params)
        end
      end

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

    describe "SA summary" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      context "tax year validation" do
        it do
          expect do
            individual_income.sa_summary("2018", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear format is invalid")
        end

        it do
          expect do
            individual_income.sa_summary("2018-", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear format is invalid")
        end

        it do
          expect do
            individual_income.sa_summary("2018-1", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear format is invalid")
        end

        it do
          expect do
            individual_income.sa_summary("2018-18", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear format is invalid")
        end

        it do
          expect do
            individual_income.sa_summary("2018-20", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear format is invalid")
        end

        it do
          expect do
            individual_income.sa_summary("2018-19", "2017-18")
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear year is before ToTaxYear")
        end

        it do
          expect do
            individual_income.sa_summary("", to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear is missing")
        end

        it do
          expect do
            individual_income.sa_summary(nil, to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear is missing")
        end

        it do
          expect do
            individual_income.sa_summary(from_tax_year, "")
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToTaxYear is missing")
        end

        it do
          expect do
            individual_income.sa_summary(from_tax_year, nil)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToTaxYear is missing")
        end

        it do
          expect do
            individual_income.sa_summary(from_tax_year, 2000)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: ToTaxYear is not a String")
        end

        it do
          expect do
            individual_income.sa_summary(2000, to_tax_year)
          end.to raise_error(HwfHmrcApiError,
                             "Attributes validation: FromTaxYear is not a String")
        end
      end

      context "call summary endpoint" do
        let(:paye_request_params) do
          {
            matching_id: matching_id,
            from: from_tax_year,
            to: to_tax_year
          }
        end

        it do
          allow(HwfHmrcApi::Endpoint).to receive(:income_summary).and_return({})
          individual_income.sa_summary(from_tax_year, to_tax_year)
          expect(HwfHmrcApi::Endpoint).to have_received(:income_summary).with(access_token, paye_request_params)
        end
      end

    end
  end
end
