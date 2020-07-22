# frozen_string_literal: true

require 'oracle_ows/base'

#
# OracleOws::Housekeeping
#
module OracleOWS
  #
  # [Housekeeping Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Housekeeping%20Web%20Service%20Specifications.htm}
  #
  class HouseKeeping < Base
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
        'xmlns:hkeep' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl',
        'xmlns:room' => 'http://webservices.micros.com/og/4.3/HouseKeeping/'
      }
      # merge base + additional namespaces
      @namespaces.merge!(more_namespaces)
    end

    #
    # FetchHouseKeepingRoomStatus
    #
    # @param [Hash] options with parameters
    # @option options [String] :hotel_code is the identifier for the hotel
    # @option options [Hash] :room a hash of :from and :to parameters
    # @option options [Symbol] :from parameter in :room => { :from => 1 }
    # @option options [Symbol] :to parameter in :room => { :to => 1 }
    #
    # @return [Hash] of the result from deeply nested XML response
    #
    def room_status(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :fetch_house_keeping_room_status,
        message: {
          'HotelReference' => { '@hotelCode' => options[:hotel_code] },
          'Criteria' => {
            'FromRoom' => options[:room][:from],
            'ToRoom' => options[:room][:to],
            'RoomStatusList' => { 'Code' => 'CLEAN' },
            'HKStatusList' => { 'Code' => 'VACANT' },
            'FOStatusList' => { 'Code' => 'VACANT' },
            'ReservationStatusList' => { 'Code' => 'STAYOVER' }
          }
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:fetch_house_keeping_room_status_response, :result)

    # handle exceptions gracefully
    rescue StandardError => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end
  end
  # class Hosuekeeping
end
# module OracleOws
