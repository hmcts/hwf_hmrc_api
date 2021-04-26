# frozen_string_literal: true

require "hwf_hmrc_api"
require "pry"
require "vcr"
require "timecop"
require "hwf_hmrc_api/user_validation"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  WebMock.disable_net_connect!(allow_localhost: true)
end

VCR.configure do |c|
  # This is the directory where VCR will store its "cassettes", i.e. its
  # recorded HTTP interactions.
  c.cassette_library_dir = "spec/cassettes"

  # This line makes it so VCR and WebMock know how to talk to each other.
  c.hook_into :webmock

  # This line makes VCR ignore requests to localhost. This is necessary
  # even if WebMock's allow_localhost is set to true.
  c.ignore_localhost = true

  # ChromeDriver will make requests to chromedriver.storage.googleapis.com
  # to (I believe) check for updates. These requests will just show up as
  # noise in our cassettes unless we tell VCR to ignore these requests.
  c.ignore_hosts "chromedriver.storage.googleapis.com"
  c.before_record do |i|
    i.response.body.force_encoding("UTF-8")
  end
end
