# frozen_string_literal: true

RSpec.describe OracleOWS::HouseKeeping do
  let(:base_namespaces_keys) { %w[xmlns:env xmlns:cor] }
  let(:options) { { username: 'test_username', password: 'test_password' } }
  let(:house_keeping) { OracleOWS::HouseKeeping.new(options) }

  it 'has OracleOws::HouseKeeping class' do
    expect(OracleOWS::HouseKeeping).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'namespaces picked up' do
      expect(house_keeping.namespaces.keys).to include(*base_namespaces_keys)
    end

    it 'username picked up' do
      expect(house_keeping.username).to eql 'test_username'
    end

    it 'password picked up' do
      expect(house_keeping.password).to eql 'test_password'
    end
  end

  it 'keeps namespaces from base + additional' do
    # assign additional namespace to base
    hk_namespaces = { 'xmlns:hou' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
    house_keeping.namespaces = hk_namespaces
    expect(house_keeping.namespaces.keys).to include('xmlns:hou')
  end

  context 'SOAP client' do
    let(:header) { house_keeping.send(:soap_client).globals[:soap_header] }

    it 'ready for action' do
      expect(house_keeping.send(:soap_client)).not_to be_nil
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
      ns = house_keeping.send(:soap_client).globals[:namespaces]
      expect(ns).not_to be_nil
      expect(ns.keys).to include('xmlns:env', 'xmlns:cor')
    end

    it 'keeps namespaces updated' do
      # only base namespaces exist at this point
      ns = house_keeping.send(:soap_client).globals[:namespaces]
      expect(ns.keys).not_to include('xmlns:hou1')
      # add namespaces to base namespaces
      hk_namespaces = { 'xmlns:hou1' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
      house_keeping.namespaces = hk_namespaces
      # must be updated in the SOAP client
      ns = house_keeping.send(:soap_client).globals[:namespaces]
      expect(ns.keys).to include('xmlns:hou1')
    end
  end

  context 'API calls to fetch data' do
    let(:options) { { url: ENV['URL'], username: ENV['USERNAME'], password: ENV['PASSWORD'] } }
    # let(:base)         { OracleOws::new(options) }
    let(:house_keeping) { OracleOWS::HouseKeeping.new(options) }

    it 'room status' do
      VCR.use_cassette('room_status') do
        status = house_keeping.room_status(hotel_code: 'POSHIE', room: { from: 1, to: 1 })
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end
  end
end
