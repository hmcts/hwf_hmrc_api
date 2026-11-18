# frozen_string_literal: true

require "json"

module HwfHmrcApi
  module Mock
    # Stands in for the HMRC API: takes the path and options of an HTTP call
    # and returns the response a test individual would get.
    module Responder
      TOKEN_LIFETIME_SECONDS = 14_400

      module_function

      def call(path, options = {})
        case path
        when "/oauth/token" then token
        when "/individuals/matching" then match(JSON.parse(options[:body].to_s))
        when "/individuals/income/paye" then Income.paye(options[:query] || {})
        when "/individuals/benefits-and-credits/child-tax-credit"
          Income.tax_credits(options[:query] || {}, "child_tax_credit")
        when "/individuals/benefits-and-credits/working-tax-credit"
          Income.tax_credits(options[:query] || {}, "working_tax_credit")
        else Response.error(404, "NOT_FOUND", "The mock connection has no answer for #{path}")
        end
      end

      def token
        Response.json(200, access_token: "mock-hmrc-token", token_type: "bearer",
                           expires_in: TOKEN_LIFETIME_SECONDS, scope: "mock")
      end

      def match(details)
        individual = TestIndividuals.find_by_details(details)
        if individual.nil?
          return Response.error(403, "MATCHING_FAILED", "There is no match for the information provided")
        end

        href = "/individuals/matching/#{TestIndividuals.match_id_for(individual)}"
        Response.json(200, _links: {
                        individual: { name: "GET", href: href, title: "Get a matched individual’s information" },
                        self: { href: "/individuals/matching/" }
                      })
      end
    end
  end
end
