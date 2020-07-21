# frozen_string_literal: true

#
# OracleOws::Common
#
module OracleOWS
  # common methods to include in all classes
  module Common
    # @return [String] url => base URL for the API endpoint
    # @return [String] username => login to use like ENV['ORACLE_OWS_LOGIN']
    # @return [String] password => password to use like ENV['ORACLE_OWS_PASSWORD']
    # @return [Hash] namespaces => a hash of XML namespaces for SOAP header
    #
    #   Example:
    #   !{
    #     'xmlns:env' => 'http://schemas.xmlsoap.org/soap/envelope/',
    #     'xmlns:cor' => 'http://webservices.micros.com/og/4.3/Core/'
    #   }
    attr_accessor :url, :username, :password
    # # @return [OracleOws::Base] base class object holds connection parameters
    # attr_accessor :base
    # @return [Hash] XML namesspaces as hash
    # {#namespaces=} writer method adds more namespaces to the hash
    attr_reader :namespaces

    #
    # Merges existing namespaces hash with additional values
    #
    # @param [Hash] hash of XML namespaces to be used additionally
    #
    # @return [Hash] hash of all namespaces merged together
    #
    def namespaces=(hash = {})
      hash = {} unless hash.is_a? Hash

      @namespaces ||= {}
      @namespaces.merge!(hash)
    end

    private

    #
    # soap client object to make API calls
    #
    # @return [Savon::Client] client object ready to make calls
    #
    def soap_client
      # authentication
      credentials = { 'cor:UserName' => username, 'cor:UserPassword' => password }
      # required SOAP header
      soap_header = { 'cor:OGHeader' => { 'cor:Authentication' => { 'cor:UserCredentials' => credentials } } }
      # logging options
      log_options = { log_level: :debug, log: true, pretty_print_xml: true }
      # class name of caller object
      klass_name = self.class.name.split('::').last
      # WSDL endpoint is derived from ClassName
      options = { wsdl: "#{url}/#{klass_name}.asmx?WSDL", namespaces: namespaces, soap_header: soap_header }
      # SOAP client
      Savon.client(options.merge(log_options))
    end
  end
end
