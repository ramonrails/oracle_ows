# frozen_string_literal: true

require 'webmock/rspec'

# at least allow once
# then cache as fixture cassette
WebMock.disable_net_connect!(allow: '130.61.16.108:8080')
