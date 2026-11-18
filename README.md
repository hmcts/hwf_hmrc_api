# HwfHmrcApi

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hwf_hmrc_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hwf_hmrc_api

## Usage

### Credentials
To be able to use HMRC API, you will need three credentials. HMRC_SECRET, TOTP token and client id.
You can generate HMRC_SECRET in your account on https://developer.service.hmrc.gov.uk/.
To receive the TOTP secret, you need to speak with the team from HMRC.

### API URL
Is loaded from HMRC_API_URL env variable.

### Mock connection
Set `HMRC_API_CONNECTION=mock_hmrc` to test scenarios without calling HMRC (see [Mock connection](#mock-connection-1)).

## How to use

#### When you don't have access_token already
```ruby
attributes = {
  hmrc_secret: HMRC_SECRET,
  totp_secret: HMRC_TTP_SECRET,
  client_id: HMRC_TTP_SECRET,
}
hmrc = HwfHmrcApi.new(attributes)
# store this so you don't generate new token every call
access_token = hmrc.access_token
expires_in = hmrc.expires_in
```

#### When you stored access_token alredy
```ruby
attributes = {
  hmrc_secret: HMRC_SECRET,
  totp_secret: HMRC_TTP_SECRET,
  client_id: HMRC_TTP_SECRET,
  access_token: ACCESS_TOKEN,
  expires_in: EXPIRES_IN
}
hmrc = HwfHmrcApi.new(attributes)
```

## Mock connection

Set `HMRC_API_CONNECTION=mock_hmrc` to test scenarios without calling HMRC. The gem is used exactly as with a real connection; every HTTP call is answered from the test individuals in `lib/hwf_hmrc_api/mock/individuals` instead, and the usual response and error handling still runs. Any other value, or none, uses the real connection.

- None of the credentials or `HMRC_API_URL` are needed; a fake token `mock-hmrc-token` is issued. A cached token passed in is used as it is.
- A warning is logged each time a connection is created, and every match id starts with `mock-hmrc-`.
- `match_user` needs the first name, last name, NI number and date of birth of a test individual (case and spaces do not matter). Anything else raises `MATCHING_FAILED`.
- `paye`, `child_tax_credits` and `working_tax_credits` are mocked. The other endpoints raise `NOT_FOUND`.
- Never set `mock_hmrc` in production.

### Test individuals

| Name | DOB | NI number | Scenario |
|------|-----|-----------|----------|
| Alice Turner | 12/03/1985 | HM100001A | Monthly salary £1,850 + £75 pension, no tax credits |
| Ben Carter | 01/07/1979 | HM100002A | Four weekly payslips |
| Chloe Evans | 05/11/1990 | HM100003A | Two employers (monthly and four-weekly) |
| David Hughes | 20/01/1982 | HM100004A | Payslips on days 28, 59 and 90: one in a one-month window, three in a three-month one |
| Emma Lewis | 14/05/1988 | HM100005A | Salary + weekly child tax credit with a childcare element |
| Frank Morris | 30/09/1975 | HM100006A | Salary + weekly working tax credit |
| Grace Patel | 02/02/1993 | HM100007A | Matched, no PAYE or tax credits ("NO RESULT") |
| Harry Shah | 04/04/1980 | HM100008A | Married applicant; partner is Isla Shah |
| Isla Shah | 06/06/1981 | HM100009A | Married partner, fortnightly pay |
| Jack Reid | 12/12/1970 | HM100010A | PAYE call returns 429 `MESSAGE_THROTTLED_OUT` |
| Kate Scott | 08/08/1987 | HM100011A | Working tax credit calculated in 2099, after any window (staff app asks for a paper check) |
| Liam Ward | 10/10/1984 | HM100012A | PAYE call raises `Net::ReadTimeout` |

### Dates follow the requested window

The staff app asks for the month (or three months) before the application date, so the test individuals have no fixed dates:

- A payslip with `paymentDay: N` is paid on day N of the window (day 1 = `fromDate`). Payslips that fall after `toDate` are left out. A payslip with a fixed `paymentDate` is returned only inside the window.
- A tax credit payment without `startDate`/`endDate` runs for the whole window, and an award without `payProfCalcDate` is calculated on `fromDate`.

To add a scenario, add a YAML file to `lib/hwf_hmrc_api/mock/individuals` with a unique `internal_id` and `nino`. To make an endpoint fail, give it an `errors` entry:

```yaml
  errors:
    paye:              # or child_tax_credit / working_tax_credit
      status: 500
      code: "INTERNAL_SERVER_ERROR"
      message: "Something went wrong"
    # or: timeout: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hwf_hmrc_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
