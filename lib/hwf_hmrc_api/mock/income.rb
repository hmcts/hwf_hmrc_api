# frozen_string_literal: true

require "date"
require "net/http"

module HwfHmrcApi
  module Mock
    # PAYE and tax credit answers for the matched test individual
    module Income
      module_function

      # query: the matchId, fromDate and toDate the endpoint sends
      def paye(query)
        with_individual(query, "paye") do |individual, from, to|
          Response.json(200, paye: { income: WindowDates.paye(individual.fetch("paye", []), from, to) })
        end
      end

      # key: "child_tax_credit" or "working_tax_credit"
      def tax_credits(query, key)
        with_individual(query, key) do |individual, from, to|
          Response.json(200, applications: WindowDates.tax_credits(individual.fetch(key, []), from, to))
        end
      end

      def with_individual(query, endpoint)
        individual = TestIndividuals.find_by_match_id(query[:matchId])
        return Response.error(404, "NOT_FOUND", "The resource can not be found") if individual.nil?

        forced_error = individual.fetch("errors", {})[endpoint]
        return failure(forced_error) if forced_error

        yield individual, Date.iso8601(query[:fromDate]), Date.iso8601(query[:toDate])
      end

      # An `errors` entry is either an HTTP error (status, code, message) or `timeout: true`
      def failure(error)
        raise Net::ReadTimeout, "Net::ReadTimeout" if error["timeout"]

        Response.error(error["status"], error["code"], error["message"])
      end
    end
  end
end
