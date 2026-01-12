# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::IndividualIncome do
  subject(:individual_income) { dummy_class }

  let(:dummy_class) { Class.new { extend HwfHmrcApi::IndividualIncome } }
  let(:matching_id) { "6789" }
  let(:from_date) { "2021-01-20" }
  let(:to_date) { "2021-02-20" }
  let(:access_token) { "0f3adcfc0e6f5ace9102af880cedd279" }
  let(:tax_year_request_params) do
    {
      matching_id: matching_id,
      from: from_tax_year,
      to: to_tax_year
    }
  end
  let(:correlation_id) { "b77609d0-8a2a-0139-cebe-1e00e23ae066" }
  let(:header_info) do
    { access_token: access_token,
      correlation_id: correlation_id }
  end

  context "missing matching_id" do
    before { allow(dummy_class).to receive(:matching_id).and_return nil }

    it "Paye" do
      expect do
        individual_income.paye(from_date, to_date, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Income summary" do
      expect do
        individual_income.sa_summary("2018-19", "2019-20", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Income interest and dividends" do
      expect do
        individual_income.sa_interest_dividends("2018-19", "2019-20", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Income self employements" do
      expect do
        individual_income.sa_self_employments("2018-19", "2019-20", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Income uk properties" do
      expect do
        individual_income.sa_uk_properties("2018-19", "2019-20", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end

    it "Income foreign" do
      expect do
        individual_income.sa_foreign("2018-19", "2019-20", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Params validation: Mathching ID is missing")
    end
  end

  context "matching_id present" do
    before do
      allow(dummy_class).to receive_messages(matching_id: matching_id, access_token: access_token,
                                             header_info: header_info)
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
          individual_income.paye(from_date, to_date, correlation_id)
          expect(HwfHmrcApi::Endpoint).to have_received(:income_paye).with(header_info, paye_request_params)
        end
      end

      it_behaves_like "Date validation", described_class, :paye
    end

    describe "SA summary" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      it_behaves_like "Tax year validation", :sa_summary

      context "call summary endpoint" do
        it do
          allow(HwfHmrcApi::Endpoint).to receive(:income_summary).and_return({})
          individual_income.sa_summary(from_tax_year, to_tax_year, correlation_id)
          expect(HwfHmrcApi::Endpoint).to have_received(:income_summary).with(header_info, tax_year_request_params)
        end
      end
    end

    describe "SA dividends and interest" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      it_behaves_like "Tax year validation", :sa_interest_dividends

      it "call income_interest_dividends" do
        allow(HwfHmrcApi::Endpoint).to receive(:income_interest_dividends).and_return({})
        individual_income.sa_interest_dividends(from_tax_year, to_tax_year, correlation_id)
        expect(HwfHmrcApi::Endpoint).to have_received(:income_interest_dividends).with(header_info,
                                                                                       tax_year_request_params)
      end
    end

    describe "SA self employements" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      it_behaves_like "Tax year validation", :sa_self_employments

      it "call income_interest_dividends" do
        allow(HwfHmrcApi::Endpoint).to receive(:income_self_employments).and_return({})
        individual_income.sa_self_employments(from_tax_year, to_tax_year, correlation_id)
        expect(HwfHmrcApi::Endpoint).to have_received(:income_self_employments).with(header_info,
                                                                                     tax_year_request_params)
      end
    end

    describe "SA uk properties" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      it_behaves_like "Tax year validation", :sa_uk_properties

      it "call income_interest_dividends" do
        allow(HwfHmrcApi::Endpoint).to receive(:income_uk_properties).and_return({})
        individual_income.sa_uk_properties(from_tax_year, to_tax_year, correlation_id)
        expect(HwfHmrcApi::Endpoint).to have_received(:income_uk_properties).with(header_info,
                                                                                  tax_year_request_params)
      end
    end

    describe "SA foreign" do
      let(:from_tax_year) { "2018-19" }
      let(:to_tax_year) { "2020-21" }

      it_behaves_like "Tax year validation", :sa_foreign

      it "call income_foreign" do
        allow(HwfHmrcApi::Endpoint).to receive(:income_foreign).and_return({})
        individual_income.sa_foreign(from_tax_year, to_tax_year, correlation_id)
        expect(HwfHmrcApi::Endpoint).to have_received(:income_foreign).with(header_info,
                                                                            tax_year_request_params)
      end
    end
  end
end
