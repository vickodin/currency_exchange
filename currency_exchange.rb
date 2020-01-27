# frozen_string_literal: true

# Currency Exchange operations
#
#  Usage:
#  `CurrenceExchange.convert(amount, from_currency, to_currency)`
#  where `from_currency` and `to_currency` are currency codes:
#  https://en.wikipedia.org/wiki/ISO_4217#Active_codes
#
#  Examples:
#  We want to exchange 1 "Turkish lira" to "United States dollar":
#  `CurrencyExchange.convert(1, :try, :usd)`
#  => 0.16850611053490844
module CurrencyExchange
  require 'json'
  require 'net/http'

  EXTERNAL_SOURCE = 'https://www.cbr-xml-daily.ru/daily_json.js'

  # We need it in case when we have deal with RUB currency:
  RUB_STRUCTURE = {
    'NumCode' => '643',
    'CharCode' => 'RUB',
    'Nominal' => 1,
    'Name' => 'Российский рубль',
    'Value' => 1,
    'Previous' => 1
  }.freeze

  # Path for local json cache:
  CACHE_JSON_PATH = '/tmp/daily_json.js'
  # Cache time to live (in seconds):
  CACHE_TTL = 60 * 60

  # Custom Errors for case when something wrong. You can catch them in your code
  class CurrencyCodeError < StandardError; end
  class ExternalSourceError < StandardError; end

  class << self
    # Main method:
    def convert(amount, from, to)
      amount * exchange_rate(from, to)
    end

    # also usefull for public usage:
    def exchange_rate(from, to)
      rate_map(from) / rate_map(to).to_f
    end

    private

    # Auxiliary internal methods:
    def rate_map(code)
      currency = rates[code.to_s.upcase]
      raise CurrencyCodeError unless currency

      currency['Value'] / currency['Nominal'].to_f
    end

    def rates
      @rates ||= prepare_rates.merge('RUB' => RUB_STRUCTURE)
    end

    def prepare_rates
      data = cache_valid? ? cache : read_web
      JSON.parse(data)['Valute']
    rescue JSON::ParserError
      raise ExternalSourceError
    end

    def cache_valid?
      return false unless File.exist?(CACHE_JSON_PATH)

      change_time = File.new(CACHE_JSON_PATH).ctime
      return false if Time.now > change_time + CACHE_TTL

      true
    end

    def cache
      File.open(CACHE_JSON_PATH, &:read)
    end

    def save_cache(body)
      File.open(CACHE_JSON_PATH, 'w+') do |f|
        f << body
      end
    end

    def read_web
      response = Net::HTTP.get_response(URI(EXTERNAL_SOURCE))
      raise ExternalSourceError unless response.is_a?(Net::HTTPSuccess)

      save_cache(response.body)
      response.body
    rescue JSON::ParserError
      raise ExternalSourceError
    end
  end
end
