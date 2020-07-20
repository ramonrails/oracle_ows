# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

#
# OracleOws::GuestServices
#
module OracleOws
  #
  # [Guest Services Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Guest%20Services%20Web%20Service%20Specification.htm}
  #
  class GuestServices
    # @return [OracleOws::Base] base class object holds connection parameters
    attr_accessor :base
    # @return [Hash] XML namesspaces as hash
    # {#namespaces=} writer method adds more namespaces to the hash
    attr_reader :namespaces

    #
    # Initialize parameters into usage attributes
    #
    # @param [OracleOws::Base] base object with connection parameters
    #
    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for HouseKeeping API calls
      guest_services_namespaces = {
        'xmlns:gue' => 'http://webservices.micros.com/og/4.3/GuestServices/',
        'xmlns:hot' => 'http://webservices.micros.com/og/4.3/HotelCommon/'
      }
      # merge base + HouseKeeping namespaces
      @namespaces = base.namespaces.merge(guest_services_namespaces)
      # we will use this as a buffer
      @operations = []
    end

    
    #
    # Merges existing namespaces hash with additional values
    #
    # @param [Hash] hash of XML namespaces to be used additionally
    #
    # @return [Hash] hash of all namespaces merged together
    #
    def namespaces=(hash = {})
      @namespaces ||= {}
      @namespaces.merge!(hash)
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
          'HotelReference'     => {
            '@hotelCode' => options[:hotel_code]
          },
          'RoomNumber'         => options[:room],
          'RoomStatus'         => 'Clean',
          'TurnDownStatus'     => 'Completed',
          'GuestServiceStatus' => 'DoNotDisturb'
        }
      )

      # fetch the response safely (without exception or too many conditional blocks)
      response.body.dig(:update_room_status_response, :result)

    # handle exceptions gracefully
    rescue StandardError => e
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
    rescue StandardError => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end

    #
    # Operations possible on this endpoint
    #
    # @return [Array<Symbol>] method calls that can be made
    #
    def operations
      # if we fetched it once, use it as buffer
      return @operations unless @operations.blank?

      # NOTE: invalid WSDL URL? better safe than sorry with exception
      #   * check http, https
      #   * must be beginning of the string
      #   * to_s + strip, just in case :)
      client = soap_client
      return [] unless client.globals[:wsdl].to_s.strip.match?('^https?://')

      # memoization
      @operations = client&.operations

    # WARN: external API. handle with care.
    rescue Errno::ENOENT => e
      # malformatted URL. probably the URL or the path is incorrect
    rescue StandardError => e
      # handle all other exceptions gracefully
    ensure
      # keep the buffer blank. attempt to fetch again next time
      @operations = []
    end

    private

      #
      # soap client object to make API calls
      #
      # @return [Savon::Client] client object ready to make calls
      #
      def soap_client
        # authentication
        credentials = { 'cor:UserName' => base.username, 'cor:UserPassword' => base.password }
        # required SOAP header
        soap_header = { 'cor:OGHeader' => { 'cor:Authentication' => { 'cor:UserCredentials' => credentials } } }
        # logging options
        log_options = { log_level: :debug, log: true, pretty_print_xml: true }
        # options
        options = { wsdl: "#{base.url}/GuestServices.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
        # SOAP client
        Savon.client(options.merge(log_options))
      end
  end
  # class Hosuekeeping
end
# module OracleOws
