# frozen_string_literal: true

# environment
require 'dotenv/load'
# load config for gem
require 'config/dotenv'

# gem components
#
# base components
require 'oracle_ows/base'
require 'oracle_ows/error'

# feature components
#
require 'oracle_ows/guest_services'
require 'oracle_ows/house_keeping'
require 'oracle_ows/information'
require 'oracle_ows/reservation'
require 'oracle_ows/resv_advanced'
require 'oracle_ows/version'
