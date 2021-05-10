# frozen_string_literal: true

RSpec.shared_examples_for "Date validation" do |klass, method_name|
  context "tax year validation" do
    let(:from_tax_year) { "2018-19" }
    let(:to_tax_year) { "2020-21" }
    let(:dummy_class) { Class.new { extend klass } }
    before do
      allow(dummy_class).to receive(:matching_id).and_return "654654654"
    end

    context "date present validation" do
      it do
        expect do
          dummy_class.send(method_name, "", to_date)
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: FromDate is missing")
      end

      it do
        expect do
          dummy_class.send(method_name, nil, to_date)
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: FromDate is missing")
      end

      it do
        expect do
          dummy_class.send(method_name, from_date, "")
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: ToDate is missing")
      end

      it do
        expect do
          dummy_class.send(method_name, from_date, nil)
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: ToDate is missing")
      end

      it do
        expect do
          dummy_class.send(method_name, 123, to_date)
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: FromDate is not a String")
      end
    end

    context "date format YYYY-MM-DD" do
      it do
        expect do
          dummy_class.send(method_name, "21-01-2000", to_date)
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: FromDate format is invalid")
      end

      it do
        expect do
          dummy_class.send(method_name, from_date, "21-01-2021")
        end.to raise_error(HwfHmrcApiError,
                           "Attributes validation: ToDate format is invalid")
      end
    end
  end
end
