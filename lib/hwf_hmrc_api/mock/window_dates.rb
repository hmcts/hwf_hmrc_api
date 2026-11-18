# frozen_string_literal: true

require "date"

module HwfHmrcApi
  module Mock
    # Puts undated test data inside the requested date window - see the README
    module WindowDates
      module_function

      # A payslip with `paymentDay: N` is paid on day N of the window (day 1 = fromDate).
      # Payslips paid outside the window are left out, as HMRC does.
      def paye(payslips, from, to)
        dated = payslips.map do |payslip|
          payslip = payslip.dup
          day = payslip.delete("paymentDay") || 1
          payslip["paymentDate"] ||= (from + day - 1).iso8601
          payslip
        end

        dated.select { |payslip| Date.parse(payslip["paymentDate"]).between?(from, to) }
      end

      # Undated payments run for the whole window; an undated award is calculated on fromDate.
      def tax_credits(applications, from, to)
        applications.map do |application|
          awards = application.fetch("awards", []).map { |award| dated_award(award, from, to) }
          application.merge("awards" => awards)
        end
      end

      def dated_award(award, from, to)
        payments = award.fetch("payments", []).map do |payment|
          { "startDate" => from.iso8601, "endDate" => to.iso8601 }.merge(payment)
        end
        { "payProfCalcDate" => from.iso8601 }.merge(award).merge("payments" => payments)
      end
    end
  end
end
