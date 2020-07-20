# frozen_string_literal: true

require 'savon'
require 'oracle_ows/base'

#
# OracleOws::Information
#
module OracleOws
  # [Information Web Service]
  # {https://docs.oracle.com/cd/E90572_01/docs/Information%20Web%20Service%20Specifications.htm}
  class Information
    # @return [OracleOws::Base] base object with connection paremeters
    attr_accessor :base
    # @return [Hash] XML namespaces for SOAP API
    attr_reader :namespaces # writer defined below

    #
    # initialize the API endpoint object
    #
    # @param [OracleOws::Base] base object with initial parameters
    #
    def initialize(base)
      # keep the base for credentials
      @base = base
      # we need these for API calls
      information_namespaces = {
        'xmlns:inf' => 'http://webservices.micros.com/ows/5.1/Information.wsdl'
      }
      # merge base + this API namespaces
      @namespaces = base.namespaces.merge(information_namespaces)
      # we will use this as a buffer
      @operations = []
    end

    #
    # namespaces (writer) merges additional namespaces into existing ones
    #
    # @param [Hash] hash of XML namespaces
    #
    # @return [Hash] of all namespaces into single hash
    #
    def namespaces=(hash = {})
      @namespaces ||= {}
      @namespaces.merge!(hash)
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

    #
    # actions possible on this API endpoint
    #
    # @return [Array<Symbol>] array of symbolised actions
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
        options = { wsdl: "#{base.url}/Information.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
        # SOAP client
        Savon.client(options.merge(log_options))
      end
  end
  # class
end
# module OracleOws
