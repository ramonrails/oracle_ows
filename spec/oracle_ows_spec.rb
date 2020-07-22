# frozen_string_literal: true

RSpec.describe OracleOWS do
  it 'has a version number' do
    expect(OracleOWS::VERSION).not_to be_nil
  end

  it 'has OracleOws::Base' do
    expect(OracleOWS::Base).not_to be_nil
  end
end
