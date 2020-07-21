# frozen_string_literal: true

require 'oracle_ows/base'

#
# OracleOws::Reservation
#
module OracleOWS
  # [Reservation Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Reservation%20Web%20Service%20Specifications.htm}
  class Reservation < Base
    #
    # initialize
    #
    # @param [Hash] options for connection
    #
    def initialize(options = {})
      # call the parent method, all arguments passed
      super

      # we need these for API calls
      more_namespaces = {
        'xmlns:res' => 'http://webservices.micros.com/ows/5.1/Reservation.wsdl',
        'xmlns:res1' => 'http://webservices.micros.com/og/4.3/Reservation/'
      }
      # merge base + this API namespaces
      @namespaces.merge!(more_namespaces)
    end

    #
    # PreCheckin
    #
    # @param [Hash] options of parameters for the API call
    # @option options [String] :hotel_code to identify the hotel
    # @option options [String] :chain_code to identify the chain of hotels it belongs to
    # @option options [String] :confirmation number of the check in
    #
    # @return [Hash] result hash from the deeply nested XML response
    #
    def pre_checkin(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :pre_checkin,
        message: {
          'HotelReference' => {
            '@hotelCode' => options[:hotel_code],
            '@chainCode' => options[:chain_code]
          },
          'ConfirmationNumber' => options[:confirmation]
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:pre_checkin_response, :result)

    # handle exceptions gracefully
    rescue StandardError => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end

    # Usage:
    #   method({ hotel_code: 'ABC', type: 'ABC', source: 'ABC' })
    def fetch_booked_inventory_items(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :fetch_booked_inventory_items,
        message: {
          'HotelReference' => { '@hotelCode' => options[:hotel_code] } #,
          # 'ConfirmationNumber' => { '@type' => options[:type], '@source' => options[:source] }
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:fetch_booked_inventory_items_response, :result)

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
