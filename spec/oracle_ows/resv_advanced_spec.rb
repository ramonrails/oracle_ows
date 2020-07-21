# frozen_string_literal: true

RSpec.describe OracleOWS::ResvAdvanced do
  let(:base_namespaces_keys) { %w[xmlns:env xmlns:cor] }
  let(:options) { { username: 'test_username', password: 'test_password' } }
  let(:reservation_advanced) { OracleOWS::ResvAdvanced.new(options) }

  it 'has OracleOws::ResvAdvanced class' do
    expect(OracleOWS::ResvAdvanced).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'namespaces picked up' do
      expect(reservation_advanced.namespaces.keys).to include(*base_namespaces_keys)
    end

    it 'username picked up' do
      expect(reservation_advanced.username).to eql 'test_username'
    end

    it 'password picked up' do
      expect(reservation_advanced.password).to eql 'test_password'
    end
  end

  it 'keeps namespaces from base + additional' do
    # assign additional namespace to base
    hk_namespaces = { 'xmlns:inf' => 'http://webservices.micros.com/ows/5.1/ReservationAdvanced.wsdl' }
    reservation_advanced.namespaces = hk_namespaces
    expect(reservation_advanced.namespaces.keys).to include('xmlns:inf')
  end

  context 'SOAP client' do
    let(:header) { reservation_advanced.send(:soap_client).globals[:soap_header] }

    it 'ready for action' do
      expect(reservation_advanced.send(:soap_client)).not_to be_nil
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
      ns = reservation_advanced.send(:soap_client).globals[:namespaces]
      expect(ns).not_to be_nil
      expect(ns.keys).to include('xmlns:env', 'xmlns:cor')
    end

    it 'keeps namespaces updated' do
      # only base namespaces exist at this point
      ns = reservation_advanced.send(:soap_client).globals[:namespaces]
      expect(ns.keys).not_to include('xmlns:hou1')
      # add namespaces to base namespaces
      hk_namespaces = { 'xmlns:hou1' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
      reservation_advanced.namespaces = hk_namespaces
      # must be updated in the SOAP client
      ns = reservation_advanced.send(:soap_client).globals[:namespaces]
      expect(ns.keys).to include('xmlns:hou1')
    end
  end

  context 'API calls to fetch data' do
    let(:options) { { url: ENV['URL'], username: ENV['USERNAME'], password: ENV['PASSWORD'] } }
    let(:reservation_advanced) { OracleOWS::ResvAdvanced.new(options) }

    it 'reservation advanced - checkin' do
      VCR.use_cassette('reservation_advanced_checkin') do
        status = reservation_advanced.checkin(hotel_code: 'POSHIE')
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end

    it 'reservation advanced - checkout' do
      VCR.use_cassette('reservation_advanced_checkout') do
        status = reservation_advanced.checkout(hotel_code: 'POSHIE')
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end
  end
end
