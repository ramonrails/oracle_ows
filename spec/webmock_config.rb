# frozen_string_literal: true

require 'webmock/rspec'

# extract URL domain name and port, between `//` and `/` in the URL
# at least allow once
# then cache as fixture cassette
WebMock.disable_net_connect!(allow: ENV['URL'].split('//').last.split('/').first)
