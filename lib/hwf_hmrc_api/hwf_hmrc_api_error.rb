# frozen_string_literal: true

class HwfHmrcApiError < StandardError
  attr_reader :error_type

  def initialize(msg = "My default message", error_type = :default)
    @error_type = error_type
    super(msg)
  end
end
