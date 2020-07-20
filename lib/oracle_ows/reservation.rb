# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

#
# OracleOws::Reservation
#
module OracleOws
  # [Reservation Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Reservation%20Web%20Service%20Specifications.htm}
  class Reservation
    attr_accessor :base
    attr_reader :namespaces # writer defined below

    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for API calls
      reservation_namespaces = {
        'xmlns:res' => 'http://webservices.micros.com/ows/5.1/Reservation.wsdl',
        'xmlns:res1' => 'http://webservices.micros.com/og/4.3/Reservation/'
      }
      # merge base + this API namespaces
      @namespaces = base.namespaces.merge(reservation_namespaces)
      # we will use this as a buffer
      @operations = []
    end

    # no override. just merge additionally
    def namespaces=(hash = {})
      @namespaces ||= {}
      @namespaces.merge!(hash)
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

    # all possible operations (API calls)
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

      # always fetch the latest SOAP client
      #   * updated credentials and namespaces
      def soap_client
        # authentication
        credentials = { 'cor:UserName' => base.username, 'cor:UserPassword' => base.password }
        # required SOAP header
        soap_header = { 'cor:OGHeader' => { 'cor:Authentication' => { 'cor:UserCredentials' => credentials } } }
        # logging options
        log_options = { log_level: :debug, log: true, pretty_print_xml: true }
        # options
        options = { wsdl: "#{base.url}/Reservation.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
        # SOAP client
        Savon.client(options.merge(log_options))
      end
  end
  # class
end
# module OracleOws
