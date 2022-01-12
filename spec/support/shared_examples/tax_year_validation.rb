# frozen_string_literal: true

RSpec.shared_examples_for "Tax year validation" do |method_name|
  context "tax year validation" do
    let(:from_tax_year) { "2018-19" }
    let(:to_tax_year) { "2020-21" }
    let(:individual_income) { Class.new { extend HwfHmrcApi::IndividualIncome } }
    let(:correlation_id) { "b77609d0-8a2a-0139-cebe-1e00e23ae066" }

    before do
      allow(individual_income).to receive(:matching_id).and_return "654654654"
    end

    it do
      expect do
        individual_income.send(method_name, "2018", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear format is invalid")
    end

    it do
      expect do
        individual_income.send(method_name, "2018-", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear format is invalid")
    end

    it do
      expect do
        individual_income.send(method_name, "2018-1", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear format is invalid")
    end

    it do
      expect do
        individual_income.send(method_name, "2018-18", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear format is invalid")
    end

    it do
      expect do
        individual_income.send(method_name, "2018-20", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear format is invalid")
    end

    it do
      expect do
        individual_income.send(method_name, "2018-19", "2017-18", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear year is before ToTaxYear")
    end

    it do
      expect do
        individual_income.send(method_name, "", to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear is missing")
    end

    it do
      expect do
        individual_income.send(method_name, nil, to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear is missing")
    end

    it do
      expect do
        individual_income.send(method_name, from_tax_year, "", correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: ToTaxYear is missing")
    end

    it do
      expect do
        individual_income.send(method_name, from_tax_year, nil, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: ToTaxYear is missing")
    end

    it do
      expect do
        individual_income.send(method_name, from_tax_year, 2000, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: ToTaxYear is not a String")
    end

    it do
      expect do
        individual_income.send(method_name, 2000, to_tax_year, correlation_id)
      end.to raise_error(HwfHmrcApiError,
                         "Attributes validation: FromTaxYear is not a String")
    end
  end
end
