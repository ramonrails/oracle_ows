# frozen_string_literal: true

require 'oracle_ows/base'

#
# OracleOws::ReservationAdvanced
#
module OracleOWS
  # [Reservation Advanced Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Reservation%20Advanced%20Web%20Service%20Specifications.htm}
  class ResvAdvanced < Base
    #
    # initialize the object
    #
    # @param [OracleOws::Base] base parameters
    #
    def initialize(options = {})
      # call the parent method, all arguments passed
      super

      # we need these for API calls
      more_namespaces = {
        'xmlns:rsa' => 'http://webservices.micros.com/og/4.3/ResvAdvanced/',
        'xmlns:com' => 'http://webservices.micros.com/og/4.3/Common/',
        'xmlns:hot' => 'http://webservices.micros.com/og/4.3/HotelCommon/',
        'xmlns:res' => 'http://webservices.micros.com/og/4.3/Reservation/'
      }
      # merge base + additional namespaces
      @namespaces.merge!(more_namespaces)
    end

    #
    # CheckIn
    #
    # @param [Hash] options for API call
    # @option options [String] :hotel_code to identify the hotel
    # @option options [String] :key_1 Key #1
    # @option options [String] :key_2 Key #2
    # @option options [String] :key_3 Key #3
    # @option options [String] :key_4 Key #4
    #
    # @return [Hash] result hash from deeply nested XML Response
    #
    def checkin(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :check_in,
        message: {
          'ReservationRequest' => {
            'HotelReference' => { '@hotelCode' => options[:hotel_code] },
            'KeyTrack' => {
              '@Key1Track' => options[:key_1],
              '@Key2Track' => options[:key_2],
              '@Key3Track' => options[:key_3],
              '@Key4Track' => options[:key_4]
            }
          }
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:check_in_response, :result)

    # handle exceptions gracefully
    rescue OracleOWS::Error => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end

    #
    # CheckOut
    #
    # @param [Hash] options for API call
    # @option options [String] :hotel_code to identify the hotel
    # @option options [String] :key_1 Key #1
    # @option options [String] :key_2 Key #2
    # @option options [String] :key_3 Key #3
    # @option options [String] :key_4 Key #4
    #
    # @return [Hash] result hash from deeply nested XML Response
    #
    def checkout(options = {})
      return {} if options.blank?

      response = soap_client.call(
        :check_out,
        message: {
          'ReservationRequest' => {
            'HotelReference' => { '@hotelCode' => options[:hotel_code] },
            'KeyTrack' => {
              '@Key1Track' => options[:key_1],
              '@Key2Track' => options[:key_2],
              '@Key3Track' => options[:key_3],
              '@Key4Track' => options[:key_4]
            }
          }
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:check_out_response, :result)

    # handle exceptions gracefully
    rescue OracleOWS::Error => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end
  end
  # class
end
# module OracleOws
