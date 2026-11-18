# frozen_string_literal: true

# Answers the gem's HTTP calls from test individuals when HMRC_API_CONNECTION=mock_hmrc.
# See the "Mock connection" section of the README.
require_relative "mock/response"
require_relative "mock/test_individuals"
require_relative "mock/window_dates"
require_relative "mock/income"
require_relative "mock/responder"
