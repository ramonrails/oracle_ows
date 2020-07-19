# frozen_string_literal: true

# c = Savon.client(wsdl: 'http://130.61.16.108:8080/OWS_WS_51/HouseKeeping.asmx?wsdl')
#
module OracleOws
  # base class
  class Base
    attr_accessor :url, :username, :password, :namespaces

    # ows = OracleOws::Base.new( { url: 'https://...', username: 'abc', ... } )
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
