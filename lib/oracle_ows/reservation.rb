# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

module OracleOws
  # OracleOws::Reservation
  class Reservation
    attr_accessor :base
    attr_reader :namespaces # writer defined below

    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for API calls
      reservation_namespaces = {
        'xmlns:res' => 'http://webservices.micros.com/ows/5.1/Reservation.wsdl'
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

    # action: hotel reservation
    # Usage:
    #   hotel_reservation({ hotel_code: 'ABC', type: 'ABC', source: 'ABC' })
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

    # # handle exceptions gracefully
    # rescue StandardError => e
    #   # handle exception gracefully
    # ensure
    #   {} # at least return a blank hash
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
