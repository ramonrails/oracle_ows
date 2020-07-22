# frozen_string_literal: true

# environment
require 'dotenv'
Dotenv.load('./.env')
# load config for gem
require 'config/dotenv'

# gem components
require 'oracle_ows/version'
require 'oracle_ows/base'
require 'oracle_ows/guest_services'
require 'oracle_ows/house_keeping'
require 'oracle_ows/information'
require 'oracle_ows/reservation'
require 'oracle_ows/resv_advanced'

#
# OracleOws::Error handler for the gem
#
module OracleOWS
  class Error < StandardError; end
  # Error handling code goes here...
end
