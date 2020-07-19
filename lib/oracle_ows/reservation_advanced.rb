# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

module OracleOws
  # OracleOws::ReservationAdvanced
  class ReservationAdvanced
    attr_accessor :base
    attr_reader :namespaces # writer defined below

    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for API calls
      more_namespaces = {
        'xmlns:rsa' => 'http://webservices.micros.com/og/4.3/ResvAdvanced/',
        'xmlns:com' => 'http://webservices.micros.com/og/4.3/Common/',
        'xmlns:hot' => 'http://webservices.micros.com/og/4.3/HotelCommon/',
        'xmlns:res' => 'http://webservices.micros.com/og/4.3/Reservation/'
      }
      # merge base + this API namespaces
      @namespaces = base.namespaces.merge(more_namespaces)
      # we will use this as a buffer
      @operations = []
    end

    # no override. just merge additionally
    def namespaces=(hash = {})
      @namespaces ||= {}
      @namespaces.merge!(hash)
    end

    # Usage:
    #   method({ hotel_code: 'ABC' })
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
    rescue StandardError => e
      # handle exception gracefully
    ensure
      {} # at least return a blank hash
    end

    # Usage:
    #   method({ hotel_code: 'ABC' })
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
        options = { wsdl: "#{base.url}/ResvAdvanced.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
        # SOAP client
        Savon.client(options.merge(log_options))
      end
  end
  # class
end
# module OracleOws
