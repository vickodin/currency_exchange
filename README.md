# Currency Exchange Module

## Description

Currency Exchange abilities in your ruby code.

This module based on https://www.cbr-xml-daily.ru/daily_json.js data.


## Usage

`CurrenceExchange.convert(amount, from_currency, to_currency)`

where `from_currency` and `to_currency` are currency codes from:
https://en.wikipedia.org/wiki/ISO_4217#Active_codes

*Real sample*:

`CurrencyExchange.convert(1, :try, :usd).round(2)`
` => 0.17`

## Tests

1. Install rspec

`gem install rspec`

2. run spec

`rspec currency_exchange_spec.rb`
