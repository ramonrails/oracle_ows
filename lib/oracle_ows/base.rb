# frozen_string_literal: true

require 'oracle_ows/common'

#
# Oracle Hospitality OPERA Web Self-Service
# (Specifications)[https://docs.oracle.com/cd/E90572_01/index.html]
#
module OracleOWS
  #
  # OracleOws::Base stores basic parameters to connect to the service
  #
  class Base
    include OracleOWS::Common

    #
    # Instantiates the OracleOWS::Base object
    #
    # @param [Hash] options contains a hash of parameters to beused for every API call
    # @option options [String] :url base URL of the SOAP API endpoint
    # @option options [String] :username login username
    # @option options [String] :password password to use
    # @option options [Hash] :namespaces a hash of XML namespaces to use as headers
    #
    def initialize(options = {})
      # { url: 'http://some.domain/path/' }
      @url = options[:url]
      # { username: 'abc' }
      @username = options[:username]
      # { password: 'abc' }
      @password = options[:password]
      # basic namespaces required at least, to begin with
      @namespaces = {
        'xmlns:env' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:cor' => 'http://webservices.micros.com/og/4.3/Core/'
      }
      # merge any additional given namespaces
      @namespaces.merge!(options[:namespaces] || {})
    end
  end
end
