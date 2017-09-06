# frozen_string_literal: true

module YahooFinanceHelper
  include HTTParty

  # API docs: https://developer.yahoo.com/yql/console/?q=show%20tables&env=store://datatables.org/alltableswithkeys#h=select+*+from+yahoo.finance.xchange+where+pair+in+(%22USDMXN%22%2C+%22USDCHF%22)
  # Returns JSON for currency conversion
  def currency_search(all_currencies = false, base_currency_code = 'USD')
    # Example Query: https://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.xchange where pair in ("USDMXN", "USDCHF")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=
    # ^need to url encode

    # Result Format
    # {"query"=>{"count"=>163, "created"=>"2016-05-22T08:50:55Z", "lang"=>"en-US", "results"=>{"rate"=>[{"id"=>"USDAED", "Name"=>"USD/AED", "Rate"=>"3.6730", "Date"=>"5/21/2016", "Time"=>"12:29pm", "Ask"=>"3.6740", "Bid"=>"3.6730"}, {"id"=>"USDAFN", "Name"=>"USD/AFN", "Rate"=>"68.7100", "Date"=>"5/20/2016", "Time"=>"10:51pm", "Ask"=>"68.8100", "Bid"=>"68.7100"}, {"id"=>"USDALL", "Name"=>"USD/ALL", "Rate"=>"123.0495"...
    result = Rails.cache.fetch("#{base_currency_code}/currency_exchange", expires_in: 7.days) do
      source_currency = base_currency_code
      currency_array = all_currencies ? CountryReference.where.not(currency_code: nil).group(:currency_code).order(currency_code: :ASC).pluck(:currency_code) : ['EUR', 'GBP', 'AUD', 'CAD']

      currency_pair_string = String.new # will turn into format for yahoo sql (e.g. "USDAED", "USDGBP")
      currency_array.each_with_index do |cur, i = 0|
        if i == 0
          currency_pair_string += "\"#{source_currency}#{cur}\""
        else
          currency_pair_string += ",\"#{source_currency}#{cur}\""
        end
      end

      query_string = URI.encode("https://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.xchange where pair in (#{currency_pair_string})&format=json&diagnostics=false&env=store://datatables.org/alltableswithkeys&callback=")
      response = HTTParty.get(query_string)

      # Now format response to what we need
      result = {}
      response['query']['results']['rate'].each do |rate|
        result[(rate['id']).to_s.last(3)] = rate['Rate']
      end

      result.select { |_k, v| v == 'N/A' }.count.times do
        result[result.key('N/A')] = '0'
      end
      result
    end

    return result
  end
end
