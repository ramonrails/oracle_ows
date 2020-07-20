# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

#
# OracleOws::Housekeeping
#
module OracleOws
  # [Housekeeping Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Housekeeping%20Web%20Service%20Specifications.htm}
  class Housekeeping
    # @return [OracleOws::Base] base object with connection attributes
    attr_accessor :base
    # @return [Hash] hash of XML namespaces for headers in SOAP API call
    # {#namespaces=} merges any additional namespaces into this hash
    attr_reader :namespaces

    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for HouseKeeping API calls
      housekeeping_namespaces = {
        'xmlns:hkeep' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl',
        'xmlns:room' => 'http://webservices.micros.com/og/4.3/HouseKeeping/'
      }
      # merge base + HouseKeeping namespaces
      @namespaces = base.namespaces.merge(housekeeping_namespaces)
      # we will use this as a buffer
      @operations = []
    end

    #
    # writer method to merge any additional namespaces into single hash
    #
    # @param [Hash] hash of namespaces to merge
    #
    # @return [Hash] of all namespaces merged into single hash
    #
    def namespaces=(hash = {})
      @namespaces ||= {}
      @namespaces.merge!(hash)
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

    #
    # operations possible on this endpoint
    #
    # @return [Array<Symbol>] of all the actions available at this API endpoint
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
      # SOAP client object to make API calls
      #
      # @return [Savon::Client] ruby object for the endpoint
      #
      def soap_client
        # authentication
        credentials = { 'cor:UserName' => base.username, 'cor:UserPassword' => base.password }
        # required SOAP header
        soap_header = { 'cor:OGHeader' => { 'cor:Authentication' => { 'cor:UserCredentials' => credentials } } }
        # logging options
        log_options = { log_level: :debug, log: true, pretty_print_xml: true }
        # options
        options = { wsdl: "#{base.url}/HouseKeeping.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
        # SOAP client
        Savon.client(options.merge(log_options))
      end
  end
  # class Hosuekeeping
end
# module OracleOws
