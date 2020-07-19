# frozen_string_literal: true

RSpec.describe OracleOws::ReservationAdvanced do
  let(:options)      { { username: 'test_username', password: 'test_password' } }
  let(:base)         { OracleOws::Base.new(options) }
  let(:reservation_advanced) { OracleOws::ReservationAdvanced.new(base) }

  it 'has OracleOws::ReservationAdvanced class' do
    expect(OracleOws::ReservationAdvanced).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'base config picked up' do
      expect(reservation_advanced.base).to be(base)
    end

    it 'namespaces picked up' do
      expect(reservation_advanced.namespaces.keys).to include(*base.namespaces.keys)
    end

    it 'username picked up' do
      expect(reservation_advanced.base.username).to eql 'test_username'
    end

    it 'password picked up' do
      expect(reservation_advanced.base.password).to eql 'test_password'
    end
  end

  it 'a list of possible operations' do
    expect(reservation_advanced.operations).to be_an(Array)
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
    let(:options) do
      {
        url: 'http://130.61.16.108:8080/OWS_WS_51',
        username: 'SUPERVISOR', password: 'OPERA_1234'
      }
    end
    let(:base) { OracleOws::Base.new(options) }
    let(:reservation_advanced) { OracleOws::ReservationAdvanced.new(base) }

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