# frozen_string_literal: true

# environment
require 'dotenv'
Dotenv.load('./.env')
# load config for gem
require 'config/dotenv'

# gem components
require 'oracle_ows/version'
require 'oracle_ows/base'
require 'oracle_ows/housekeeping'
require 'oracle_ows/guest_services'
require 'oracle_ows/information'
require 'oracle_ows/reservation'
require 'oracle_ows/reservation_advanced'

#
# OracleOws::Error handler for the gem
#
module OracleOws
  class Error < StandardError; end
  # Error handling code goes here...
end
