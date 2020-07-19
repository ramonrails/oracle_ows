# frozen_string_literal: true

RSpec.describe OracleOws::Reservation do
  let(:options)      { { username: 'test_username', password: 'test_password' } }
  let(:base)         { OracleOws::Base.new(options) }
  let(:reservation) { OracleOws::Reservation.new(base) }

  it 'has OracleOws::Reservation class' do
    expect(OracleOws::Reservation).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'base config picked up' do
      expect(reservation.base).to be(base)
    end

    it 'namespaces picked up' do
      expect(reservation.namespaces.keys).to include(*base.namespaces.keys)
    end

    it 'username picked up' do
      expect(reservation.base.username).to eql 'test_username'
    end

    it 'password picked up' do
      expect(reservation.base.password).to eql 'test_password'
    end
  end

  it 'a list of possible operations' do
    expect(reservation.operations).to be_an(Array)
  end

  it 'keeps namespaces from base + additional' do
    # assign additional namespace to base
    hk_namespaces = { 'xmlns:res' => 'http://webservices.micros.com/ows/5.1/Reservation.wsdl' }
    reservation.namespaces = hk_namespaces
    expect(reservation.namespaces.keys).to include('xmlns:res')
  end

  context 'SOAP client' do
    let(:header) { reservation.send(:soap_client).globals[:soap_header] }

    it 'ready for action' do
      expect(reservation.send(:soap_client)).not_to be_nil
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
      ns = reservation.send(:soap_client).globals[:namespaces]
      expect(ns).not_to be_nil
      expect(ns.keys).to include('xmlns:env', 'xmlns:cor')
    end

    it 'keeps namespaces updated' do
      # only base namespaces exist at this point
      ns = reservation.send(:soap_client).globals[:namespaces]
      expect(ns.keys).not_to include('xmlns:hou1')
      # add namespaces to base namespaces
      hk_namespaces = { 'xmlns:hou1' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
      reservation.namespaces = hk_namespaces
      # must be updated in the SOAP client
      ns = reservation.send(:soap_client).globals[:namespaces]
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
    let(:reservation) { OracleOws::Reservation.new(base) }

    it 'fetch booked inventory items' do
      VCR.use_cassette('fetch_booked_inventory_items') do
        status = reservation.fetch_booked_inventory_items(hotel_code: 'POSHIE')
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end
  end
end
