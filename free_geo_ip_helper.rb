# frozen_string_literal: true

# Provides IP geo-location calls

module FreeGeoIpHelper
  include HTTParty
  class Location
    def self.convert_ip_to_iso2(ip)
      response = HTTParty.get('http://freegeoip.net/json/' + ip)
      return response['country_code'].to_s.empty? ? 'US' : response['country_code']
    end

    def self.convert_km_to_mi(distance)
      return distance.to_f / 1.60934
    end
  end
end
