# frozen_string_literal: true

RSpec.describe OracleOws do
  it 'has a version number' do
    expect(OracleOws::VERSION).not_to be_nil
  end

  it 'has OracleOws::Base' do
    expect(OracleOws::Base).not_to be_nil
  end
end
