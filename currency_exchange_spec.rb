# frozen_string_literal: true

require './currency_exchange'

RSpec.describe CurrencyExchange do
  context 'basic' do
    it 'loads json' do
      exchange = CurrencyExchange.convert(1, :usd, :usd)
      expect(exchange).to eq(1)
    end
  end

  context 'convert' do
    it 'turkish lira to us dollars' do
      # valid today only :)
      exchange = CurrencyExchange.convert(1, :try, :usd).round(2)
      expect(exchange).to eq(0.17)
    end
  end
end
