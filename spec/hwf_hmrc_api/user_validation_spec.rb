# frozen_string_literal: true

RSpec.describe HwfHmrcApi::UserValidation do
  let(:dummy_class) { Class.new { extend HwfHmrcApi::UserValidation } }

  let(:first_name) { "Tom" }
  let(:last_name) { "Jerry" }
  let(:nino) { "SN123456C" }
  let(:dob) { "1950-05-20" }
  describe "user validation" do
    context "presence" do
      describe "nino" do
        it "blank" do
          user = { first_name: first_name, last_name: last_name, nino: "", dob: dob }
          expect { dummy_class.user_valid?(user) }.to raise_error(HwfHmrcApiError, "User validation: NINO is missing")
        end

        it "nil" do
          user = { first_name: first_name, last_name: last_name, nino: nil, dob: dob }
          expect { dummy_class.user_valid?(user) }.to raise_error(HwfHmrcApiError, "User validation: NINO is missing")
        end
      end

      describe "dob" do
        it "blank" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: "" }
          expect { dummy_class.user_valid?(user) }.to raise_error(HwfHmrcApiError, "User validation: DOB is missing")
        end

        it "nil" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: nil }
          expect { dummy_class.user_valid?(user) }.to raise_error(HwfHmrcApiError, "User validation: DOB is missing")
        end

        it "day wrong format" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: "1950-10-40" }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: DOB has wrong format")
        end

        it "month wrong format" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: "1950-50-20" }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: DOB has wrong format")
        end

        it "year wrong format" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: "50-10-20" }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: DOB has wrong format")
        end

        it "out of year range" do
          user = { first_name: first_name, last_name: last_name, nino: nino, dob: "1900-10-20" }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: DOB is out of range")
        end
      end

      describe "first_name" do
        it "blank" do
          user = { first_name: "", last_name: last_name, nino: nino, dob: dob }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: First name is missing")
        end

        it "nil" do
          user = { first_name: nil, last_name: last_name, nino: nino, dob: dob }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: First name is missing")
        end
      end

      describe "last_name" do
        it "blank" do
          user = { first_name: first_name, last_name: "", nino: nino, dob: dob }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: Last name is missing")
        end

        it "nil" do
          user = { first_name: first_name, last_name: nil, nino: nino, dob: dob }
          expect do
            dummy_class.user_valid?(user)
          end.to raise_error(HwfHmrcApiError, "User validation: Last name is missing")
        end
      end
    end
  end
end
