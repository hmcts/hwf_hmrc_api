# frozen_string_literal: true

require "yaml"

module HwfHmrcApi
  module Mock
    # The test individuals, one YAML file each in mock/individuals
    module TestIndividuals
      DIRECTORY = File.expand_path("individuals", __dir__)
      MATCH_ID_PREFIX = "mock-hmrc-"

      module_function

      def all
        @all ||= Dir.glob(File.join(DIRECTORY, "*.yml")).map do |file|
          YAML.safe_load_file(file).fetch("individual")
        end
      end

      # HMRC needs all four details to match. Case and spaces do not matter.
      def find_by_details(details)
        all.find do |individual|
          %w[firstName lastName nino dateOfBirth].all? do |name|
            normalise(individual[name]) == normalise(details[name])
          end
        end
      end

      # The same individual always gets the same match id, so nothing has to be remembered between calls
      def match_id_for(individual)
        "#{MATCH_ID_PREFIX}#{individual["internal_id"]}"
      end

      def find_by_match_id(match_id)
        all.find { |individual| match_id_for(individual) == match_id }
      end

      def normalise(value)
        value.to_s.delete(" ").downcase
      end
    end
  end
end
