# frozen_string_literal: true

require 'oracle_ows/base'

#
# OracleOws::Information
#
module OracleOWS
  # [Information Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Information%20Web%20Service%20Specifications.htm}
  class Information < Base
    #
    # initialize the API endpoint object
    #
    # @param [OracleOws::Base] base object with initial parameters
    #
    def initialize(options = {})
      # call the parent method, all arguments passed
      super

      # we need these for API calls
      more_namespaces = {
        'xmlns:inf' => 'http://webservices.micros.com/ows/5.1/Information.wsdl'
      }
      # merge base + additional namespaces
      @namespaces.merge!(more_namespaces)
    end

    # action: hotel information
    # Usage:
    #   hotel_information({ hotel_code: 'ABC' })
    def hotel_information(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :query_hotel_information,
        message: {
          'HotelInformationQuery' => { '@hotelCode' => options[:hotel_code] }
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:hotel_information_response, :result)

    # handle exceptions gracefully
    rescue StandardError => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end
  end
  # class
end
# module OracleOws
