# frozen_string_literal: true

require "spec_helper"

RSpec.describe HwfHmrcApi::EndpointIncome do
  subject(:endoint) { HwfHmrcApi::Endpoint }

  let(:hmrc_secret) { "12345" }
  let(:totp_secret) { "base32secret3232" }
  let(:client_id) { "6789" }
  let(:access_token) { "8c656cbd605d4887c375eedffc5529b4" }

  describe "API calls" do
    context "income paye" do
      it "found a record" do
        VCR.use_cassette "income_paye_success" do
          request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e5", from: "2019-04-01",
                             to: "2019-04-28" }
          response = endoint.income_paye(access_token, request_params)
          expect(response["income"][0]).to have_key("totalTaxToDate")
        end
      end

      it "no record found" do
        VCR.use_cassette "income_paye_success_empty" do
          request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e5", from: "2019-04-02",
                             to: "2019-04-28" }
          response = endoint.income_paye(access_token, request_params)
          expect(response["income"]).to eq([])
        end
      end

      it "invalid request" do
        VCR.use_cassette "income_paye_400" do
          request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e5", from: "",
                             to: "2019-04-28" }
          expect do
            endoint.income_paye(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromDate: invalid date format")
        end
      end

      it "not found" do
        VCR.use_cassette "income_paye_404" do
          request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e4", from: "2019-04-02",
                             to: "2019-04-28" }
          expect do
            endoint.income_paye(access_token, request_params)
          end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
        end
      end
    end

    context "income summary" do
      it "found a record" do
        VCR.use_cassette "income_summary_success" do
          request_params = { matching_id: "0228b1ec-26e6-4f09-b26b-ea80217d5209", from: "2018-19",
                             to: "2019-20" }
          response = endoint.income_summary(access_token, request_params)
          expect(response["taxReturns"][0]).to have_key("taxYear")
        end
      end

      it "record empty" do
        VCR.use_cassette "income_summary_success_empty" do
          request_params = { matching_id: "b1a3ded8-50de-43b3-aa94-8c111e4df569", from: "2019-20",
                             to: "2020-21" }
          response = endoint.income_summary(access_token, request_params)
          expect(response["taxReturns"]).to eq([])
        end
      end

      context "error response" do
        it "500 error" do
          VCR.use_cassette "income_summary_500" do
            request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e5", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_summary(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INTERNAL_SERVER_ERROR - Something went wrong.")
          end
        end

        it "formatting error" do
          VCR.use_cassette "income_summary_400" do
            request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e5", from: "2019-2000",
                               to: "2019-20" }
            expect do
              endoint.income_summary(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromTaxYear: invalid tax year format")
          end
        end

        it "no record found" do
          VCR.use_cassette "income_summary_404" do
            request_params = { matching_id: "e5a25de7-9d26-4300-9986-6ea600d400e6", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_summary(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
          end
        end
      end
    end

    context "income intereset and dividend" do
      it "found a record" do
        VCR.use_cassette "income_interest_dividends_success" do
          request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2018-19",
                             to: "2019-20" }
          response = endoint.income_interest_dividends(access_token, request_params)
          expect(response["taxReturns"][0]).to have_key("interestsAndDividends")
        end
      end

      it "record empty" do
        VCR.use_cassette "income_interest_dividends_success_empty" do
          request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2019-20",
                             to: "2020-21" }
          response = endoint.income_interest_dividends(access_token, request_params)
          expect(response["taxReturns"]).to eq([])
        end
      end

      context "error response" do
        it "formatting error" do
          VCR.use_cassette "income_interest_dividends_400" do
            request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2019-2000",
                               to: "2019-20" }
            expect do
              endoint.income_interest_dividends(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromTaxYear: invalid tax year format")
          end
        end

        it "no record found" do
          VCR.use_cassette "income_interest_dividends_404" do
            request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_interest_dividends(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
          end
        end
      end
    end

    context "income self employments" do
      it "found a record" do
        VCR.use_cassette "income_self_employments_success" do
          request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2018-19",
                             to: "2019-20" }
          response = endoint.income_self_employments(access_token, request_params)
          expect(response["taxReturns"][0]).to have_key("selfEmployments")
        end
      end

      it "record empty" do
        VCR.use_cassette "income_self_employments_success_empty" do
          request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2019-20",
                             to: "2020-21" }
          response = endoint.income_self_employments(access_token, request_params)
          expect(response["taxReturns"]).to eq([])
        end
      end

      context "error response" do
        it "formatting error" do
          VCR.use_cassette "income_self_employments_400" do
            request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f9", from: "2019-2000",
                               to: "2019-20" }
            expect do
              endoint.income_self_employments(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromTaxYear: invalid tax year format")
          end
        end

        it "no record found" do
          VCR.use_cassette "income_self_employments_404" do
            request_params = { matching_id: "b5a6e337-87c3-44ac-820d-22d8abc6a1f", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_self_employments(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
          end
        end
      end
    end

    context "income uk properties" do
      it "found a record" do
        VCR.use_cassette "income_uk_properties_success" do
          request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2018-19",
                             to: "2019-20" }
          response = endoint.income_uk_properties(access_token, request_params)
          expect(response["taxReturns"][0]).to have_key("ukProperties")
        end
      end

      it "record empty" do
        VCR.use_cassette "income_uk_properties_success_empty" do
          request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2019-20",
                             to: "2020-21" }
          response = endoint.income_uk_properties(access_token, request_params)
          expect(response["taxReturns"]).to eq([])
        end
      end

      context "error response" do
        it "formatting error" do
          VCR.use_cassette "income_uk_properties_400" do
            request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2019-2000",
                               to: "2019-20" }
            expect do
              endoint.income_uk_properties(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromTaxYear: invalid tax year format")
          end
        end

        it "no record found" do
          VCR.use_cassette "income_uk_properties_404" do
            request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_uk_properties(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
          end
        end
      end
    end

    context "income foreign" do
      it "found a record" do
        VCR.use_cassette "income_foreign_success" do
          request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2018-19",
                             to: "2019-20" }
          response = endoint.income_foreign(access_token, request_params)
          expect(response["taxReturns"][0]).to have_key("foreign")
        end
      end

      it "record empty" do
        VCR.use_cassette "income_foreign_success_empty" do
          request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2019-20",
                             to: "2020-21" }
          response = endoint.income_foreign(access_token, request_params)
          expect(response["taxReturns"]).to eq([])
        end
      end

      context "error response" do
        it "formatting error" do
          VCR.use_cassette "income_foreign_400" do
            request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca2", from: "2019-2000",
                               to: "2019-20" }
            expect do
              endoint.income_foreign(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: INVALID_REQUEST - fromTaxYear: invalid tax year format")
          end
        end

        it "no record found" do
          VCR.use_cassette "income_foreign_404" do
            request_params = { matching_id: "ad4a751f-356e-4867-9eef-df722d17fca", from: "2019-20",
                               to: "2019-20" }
            expect do
              endoint.income_foreign(access_token, request_params)
            end.to raise_error(HwfHmrcApiError, "API: NOT_FOUND - The resource can not be found")
          end
        end
      end
    end
  end
end
