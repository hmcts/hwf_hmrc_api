# frozen_string_literal: true

require "spec_helper"
require "open3"
require "rbconfig"

# HMRC_API_CONNECTION=mock_hmrc answers from the test individuals in
# lib/hwf_hmrc_api/mock/individuals instead of calling HMRC.
RSpec.describe HwfHmrcApi::Mock::Responder do
  subject(:connection) { HwfHmrcApi.new(no_credentials) }

  # The staff app passes its ENV values, which are nil when not set
  let(:no_credentials) { { hmrc_secret: nil, totp_secret: nil, client_id: nil } }
  # monthly_salary.yml
  let(:alice) { { first_name: "alice", last_name: "TURNER", nino: "HM 10 00 01 A", dob: "1985-03-12" } }
  let(:from) { "2026-10-01" }
  let(:to) { "2026-10-31" }

  def match_person(first_name, last_name, nino, dob)
    connection.match_user({ first_name: first_name, last_name: last_name, nino: nino, dob: dob }, "id")
  end

  around do |example|
    original = ENV.fetch("HMRC_API_CONNECTION", nil)
    ENV["HMRC_API_CONNECTION"] = "mock_hmrc"
    example.run
  ensure
    ENV["HMRC_API_CONNECTION"] = original
  end

  before { allow($stdout).to receive(:puts) }

  describe ".new" do
    it "connects without any HMRC credentials and issues a token the caller can cache", :aggregate_failures do
      expect(connection.authentication.access_token).to eq "mock-hmrc-token"
      expect(connection.authentication.expires_in).to be > Time.now
    end

    it "accepts a token cached from an earlier connection" do
      cached = HwfHmrcApi.new(no_credentials.merge(access_token: "real-token", expires_in: "2000-01-01"))

      expect(cached.authentication.access_token).to eq "real-token"
    end

    it "warns that HMRC is not being called" do
      connection
      expect($stdout).to have_received(:puts).with(/mock_hmrc.*HMRC is not called/)
    end

    it "does not call HMRC" do
      connection.match_user(alice, "id")
      connection.paye(from, to, "id")
      connection.child_tax_credits(from, to, "id")
      connection.working_tax_credits(from, to, "id")
      expect(WebMock).not_to have_requested(:any, /.*/)
    end
  end

  describe "without the mock connection" do
    it "still needs the HMRC credentials" do
      ENV.delete("HMRC_API_CONNECTION")

      expect { HwfHmrcApi.new(no_credentials) }.to raise_error(HwfHmrcApiError, /HMRC secret is missing/)
    end
  end

  describe "#match_user" do
    it "matches on all four details, ignoring case and NI number spaces" do
      connection.match_user(alice, "id")

      expect(connection.matching_id).to eq "mock-hmrc-monthly_salary"
    end

    it "raises MATCHING_FAILED when any detail differs" do
      expect { match_person("Alice", "Turner", "HM100001A", "1985-03-13") }
        .to raise_error(HwfHmrcApiError, "API: MATCHING_FAILED - There is no match for the information provided")
    end
  end

  describe "#paye" do
    it "pays an undated payslip on its day of the window", :aggregate_failures do
      connection.match_user(alice, "id")
      income = connection.paye(from, to, "id")["income"]

      expect(income.size).to eq 1
      expect(income.first).to include("paymentDate" => "2026-10-28", "taxablePay" => 1850.0)
      expect(income.first).not_to have_key("paymentDay")
    end

    it "leaves out payslips that fall after the window and returns them in a longer one", :aggregate_failures do
      match_person("David", "Hughes", "HM100004A", "1982-01-20")

      expect(connection.paye(from, to, "id")["income"].size).to eq 1
      expect(connection.paye("2026-08-01", to, "id")["income"].map { |i| i["paymentDate"] })
        .to eq %w[2026-08-28 2026-09-28 2026-10-29]
    end

    it "returns no income for an individual without PAYE" do
      match_person("Grace", "Patel", "HM100007A", "1993-02-02")

      expect(connection.paye(from, to, "id")).to eq("income" => [])
    end

    it "raises the HTTP error set in the fixture" do
      match_person("Jack", "Reid", "HM100010A", "1970-12-12")

      expect { connection.paye(from, to, "id") }.to raise_error(HwfHmrcApiError, /MESSAGE_THROTTLED_OUT/)
    end

    it "times out when the fixture says so" do
      match_person("Liam", "Ward", "HM100012A", "1984-10-10")

      expect { connection.paye(from, to, "id") }.to raise_error(Net::ReadTimeout)
    end
  end

  describe "tax credits" do
    it "dates undated child tax credit payments and awards from the window", :aggregate_failures do
      match_person("Emma", "Lewis", "HM100005A", "1988-05-14")
      application = connection.child_tax_credits(from, to, "id").first
      award = application["awards"].first

      expect(application["id"]).to eq 7_210_565_654
      expect(award["payProfCalcDate"]).to eq "2026-10-01"
      expect(award["payments"].first).to include("startDate" => from, "endDate" => to, "amount" => 85.5)
    end

    it "keeps a calculation date set in the fixture" do
      match_person("Kate", "Scott", "HM100011A", "1987-08-08")
      award = connection.working_tax_credits(from, to, "id").first["awards"].first

      expect(award["payProfCalcDate"]).to eq "2099-01-01"
    end

    it "returns working tax credit" do
      match_person("Frank", "Morris", "HM100006A", "1975-09-30")
      award = connection.working_tax_credits(from, to, "id").first["awards"].first

      expect(award["workingTaxCredit"]["amount"]).to eq 80.0
    end

    it "returns no applications for an individual without tax credits", :aggregate_failures do
      connection.match_user(alice, "id")

      expect(connection.child_tax_credits(from, to, "id")).to eq []
      expect(connection.working_tax_credits(from, to, "id")).to eq []
    end
  end

  describe "an endpoint the mock does not cover" do
    it "raises NOT_FOUND" do
      connection.match_user(alice, "id")

      expect { connection.employments(from, to, "id") }.to raise_error(HwfHmrcApiError, /NOT_FOUND/)
    end
  end

  describe "test individuals" do
    let(:individuals) { HwfHmrcApi::Mock::TestIndividuals.all }
    # The staff app's NI number format
    let(:ni_number_format) { /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/ }

    it "each have a unique internal id and NI number", :aggregate_failures do
      expect(individuals.map { |i| i["internal_id"] }.uniq.size).to eq individuals.size
      expect(individuals.map { |i| i["nino"] }.uniq.size).to eq individuals.size
    end

    it "have NI numbers the staff app accepts" do
      expect(individuals.map { |i| i["nino"] }).to all(match(ni_number_format))
    end
  end

  describe "outside Rails" do
    it "loads everything it needs", :aggregate_failures do
      script = <<~RUBY
        require "hwf_hmrc_api"
        hwf = HwfHmrcApi.new(hmrc_secret: nil, totp_secret: nil, client_id: nil)
        hwf.match_user({ first_name: "Alice", last_name: "Turner", nino: "HM100001A", dob: "1985-03-12" }, "id")
        print hwf.paye("2026-10-01", "2026-10-31", "id")["income"].size
      RUBY
      lib = File.expand_path("../../lib", __dir__)
      output, status = Open3.capture2e({ "HMRC_API_CONNECTION" => "mock_hmrc" },
                                       RbConfig.ruby, "-I", lib, "-e", script)

      expect(status).to be_success, output
      expect(output).to end_with "1"
    end
  end
end
