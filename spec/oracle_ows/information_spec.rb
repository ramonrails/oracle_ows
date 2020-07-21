# frozen_string_literal: true

RSpec.describe OracleOWS::Information do
  let(:base_namespaces_keys) { %w[xmlns:env xmlns:cor] }
  let(:options) { { username: 'test_username', password: 'test_password' } }
  let(:information) { OracleOWS::Information.new(options) }

  it 'has OracleOws::Information class' do
    expect(OracleOWS::Information).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'namespaces picked up' do
      expect(information.namespaces.keys).to include(*base_namespaces_keys)
    end

    it 'username picked up' do
      expect(information.username).to eql 'test_username'
    end

    it 'password picked up' do
      expect(information.password).to eql 'test_password'
    end
  end

  it 'keeps namespaces from base + additional' do
    # assign additional namespace to base
    hk_namespaces = { 'xmlns:inf' => 'http://webservices.micros.com/ows/5.1/Information.wsdl' }
    information.namespaces = hk_namespaces
    expect(information.namespaces.keys).to include('xmlns:inf')
  end

  context 'SOAP client' do
    let(:header) { information.send(:soap_client).globals[:soap_header] }

    it 'ready for action' do
      expect(information.send(:soap_client)).not_to be_nil
    end

    it 'builds the SOAP header' do
      expect(header).not_to be_empty
      expect(header).to be_a(Hash)
    end

    it 'picks user credentials from base' do
      credentials = header.dig('cor:OGHeader', 'cor:Authentication', 'cor:UserCredentials')
      expect(credentials['cor:UserName']).to eql('test_username')
      expect(credentials['cor:UserPassword']).to eql('test_password')
    end

    it 'picks namespaces from base' do
      ns = information.send(:soap_client).globals[:namespaces]
      expect(ns).not_to be_nil
      expect(ns.keys).to include('xmlns:env', 'xmlns:cor')
    end

    it 'keeps namespaces updated' do
      # only base namespaces exist at this point
      ns = information.send(:soap_client).globals[:namespaces]
      expect(ns.keys).not_to include('xmlns:hou1')
      # add namespaces to base namespaces
      hk_namespaces = { 'xmlns:hou1' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
      information.namespaces = hk_namespaces
      # must be updated in the SOAP client
      ns = information.send(:soap_client).globals[:namespaces]
      expect(ns.keys).to include('xmlns:hou1')
    end
  end

  context 'API calls to fetch data' do
    let(:options) { { url: ENV['URL'], username: ENV['USERNAME'], password: ENV['PASSWORD'] } }
    let(:information) { OracleOWS::Information.new(options) }

    it 'hotel information' do
      VCR.use_cassette('hotel_information') do
        status = information.hotel_information(hotel_code: 'POSHIE')
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end
  end
end
