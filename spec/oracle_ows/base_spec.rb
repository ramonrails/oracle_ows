# frozen_string_literal: true

RSpec.describe OracleOws::Base do
  it 'accepts base parameters' do
    expect { OracleOws::Base.new(url: 'http://some.domain/path') }.not_to raise_error
  end

  it 'can assign and fetch url' do
    url = 'http://some.domain/path'
    ows = OracleOws::Base.new(url: url)
    expect(ows.url).to eql(url)
  end

  it 'can assign and fetch username' do
    name = 'test_username'
    ows = OracleOws::Base.new(username: name)
    expect(ows.username).to eql(name)
  end

  it 'can assign and fetch password' do
    password = 'test_password'
    ows = OracleOws::Base.new(password: password)
    expect(ows.password).to eql(password)
  end

  it 'can assign and fetch namespaces' do
    ows = OracleOws::Base.new
    expect(ows.namespaces).not_to be_nil
    expect(ows.namespaces.class).to be(Hash)
    expect(ows.namespaces.keys).to eql(%w[xmlns:env xmlns:cor])
  end
end
