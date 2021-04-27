# HwfHmrcApi

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/hwf_hmrc_api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

### How to use

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hwf_hmrc_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
