# frozen_string_literal: true

RSpec.describe OracleOWS::GuestServices do
  let(:base_namespaces_keys) { %w[xmlns:env xmlns:cor] }
  let(:options) { { username: 'test_username', password: 'test_password' } }
  let(:guest_services) { OracleOWS::GuestServices.new(options) }

  it 'has OracleOws::GuestServices class' do
    expect(OracleOWS::GuestServices).not_to be_nil
  end

  context 'OracleOws::Base' do
    it 'namespaces per instance' do
      expect(guest_services.namespaces.keys).to include(*base_namespaces_keys)
    end

    it 'username per instance' do
      expect(guest_services.username).to eql 'test_username'
    end

    it 'password per instance' do
      expect(guest_services.password).to eql 'test_password'
    end
  end

  it 'keeps namespaces from base + additional' do
    # assign additional namespace to base
    guest_services.namespaces = {
      'xmlns:gue' => 'http://webservices.micros.com/ows/5.1/GuestServices.wsdl'
    }
    expect(guest_services.namespaces.keys).to include(*(base_namespaces_keys << 'xmlns:gue'))
  end

  context 'SOAP client' do
    let(:header) { guest_services.send(:soap_client).globals[:soap_header] }

    it 'ready for action' do
      expect(guest_services.send(:soap_client)).not_to be_nil
    end

    it 'builds the SOAP header' do
      expect(header).not_to be_empty
      expect(header).to be_a(Hash)
    end

    it 'keeps user credentials per instance' do
      credentials = header.dig('cor:OGHeader', 'cor:Authentication', 'cor:UserCredentials')
      expect(credentials['cor:UserName']).to eql('test_username')
      expect(credentials['cor:UserPassword']).to eql('test_password')
    end

    it 'keeps namespaces per instance' do
      ns = guest_services.send(:soap_client).globals[:namespaces]
      expect(ns).not_to be_nil
      expect(ns.keys).to include('xmlns:env', 'xmlns:cor')
    end

    it 'keeps namespaces updated per instance' do
      # only base namespaces exist at this point
      ns = guest_services.send(:soap_client).globals[:namespaces]
      expect(ns.keys).not_to include('xmlns:hou1')
      # add namespaces to base namespaces
      hk_namespaces = { 'xmlns:hou1' => 'http://webservices.micros.com/ows/5.1/HouseKeeping.wsdl' }
      guest_services.namespaces = hk_namespaces
      # must be updated in the SOAP client
      ns = guest_services.send(:soap_client).globals[:namespaces]
      expect(ns.keys).to include('xmlns:hou1')
    end
  end

  context 'API calls to fetch data' do
    let(:options) { { url: ENV['URL'], username: ENV['USERNAME'], password: ENV['PASSWORD'] } }
    # let(:base) { OracleOws::Base.new(options) }
    let(:guest_services) { OracleOWS::GuestServices.new(options) }

    it 'wake up call' do
      VCR.use_cassette('wake_up_call') do
        status = guest_services.wake_up_call(hotel_code: 'POSHIE', room: 1)
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end

    it 'update room status' do
      VCR.use_cassette('update_room_status') do
        status = guest_services.update_room_status(hotel_code: 'POSHIE', room: 1)
        expect(status).not_to be_blank
        expect(status).to be_a(Hash)
      end
    end
  end
end
