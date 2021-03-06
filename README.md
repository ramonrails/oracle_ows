# OracleOWS (SOAP API)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/oracle_ows`. To experiment with that code, run `bin/console` for an interactive prompt.

[Oracle Hospitality OPERA Web Self-Service](https://docs.oracle.com/cd/E90572_01/index.html)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oracle_ows'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install oracle_ows

## Usage

    > options = { url: ENV['URL'], username: ENV['USERNAME'], password: ENV['PASSWORD'] }
    > info = OracleOWS::Information.new(options)
    > status = info.hotel_information(hotel_code: ENV['HOTEL_CODE'])
    > 
    > # basically returning some value or an error gracefully
    > => {:text=>{:text_element=>"SYSTEM ERROR", :@xmlns=>"http://webservices.micros.com/og/4.3/Common/"}, :@result_status_flag=>"FAIL"}

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ramonrails/oracle_ows. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ramonrails/oracle_ows/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OracleOws project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ramonrails/oracle_ows/blob/master/CODE_OF_CONDUCT.md).
