# frozen_string_literal: true

require 'oracle_ows/base'

#
# OracleOws::GuestServices
#
module OracleOWS
  #
  # [Guest Services Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Guest%20Services%20Web%20Service%20Specification.htm}
  #
  class GuestServices < Base
    #
    # Initialize
    #
    # @param [Hash] object with connection parameters
    #
    def initialize(options = {})
      # call the parent method, all arguments passed
      super

      # we need these for API calls
      more_namespaces = {
        'xmlns:gue' => 'http://webservices.micros.com/og/4.3/GuestServices/',
        'xmlns:hot' => 'http://webservices.micros.com/og/4.3/HotelCommon/'
      }
      # merge base + additional namespaces
      @namespaces.merge!(more_namespaces)
    end

    #
    # Update Room Status
    #
    # @param [Hash] options to update the room status
    # @option options [String] :hotel_code code of the hotel
    # @option options [Numeric, String] :room number to update
    #
    # @return [Hash] result hash extracted from the deply nested XML
    #
    def update_room_status(options = {})
      # save resources if we have nothing to do
      return {} if options.blank?

      # make the SOAP API call
      response = soap_client.call(
        # endpoint action
        :update_room_status,
        # payload
        message: {
          'HotelReference' => {
            '@hotelCode' => options[:hotel_code]
          },
          'RoomNumber' => options[:room],
          'RoomStatus' => 'Clean',
          'TurnDownStatus' => 'Completed',
          'GuestServiceStatus' => 'DoNotDisturb'
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:update_room_status_response, :result)

    # handle exceptions gracefully
    rescue OracleOWS::Error => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end

    #
    # Wake Up Call
    #
    # @param [Hash] options parameters
    # @option options [String] :hotel_code is the code of the hotel
    # @option options [Numeric, String] :room number
    #
    # @return [Hash] result hash from the deeply nested XML response
    #
    def wake_up_call(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :wake_up_call,
        message: {
          'HotelReference' => { '@hotelCode' => options[:hotel_code] },
          'RoomNumber' => options[:room]
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:wake_up_call_response, :result)

    # handle exceptions gracefully
    rescue OracleOWS::Error => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end
  end
  # class Hosuekeeping
end
# module OracleOws
