# frozen_string_literal: true

module GoogleHelper
  include HTTParty
  class GooglePlaces
    # Places Search docs: https://developers.google.com/places/web-service/search?authuser=2#TextSearchRequests
    # WEIRD NOTE: type = geocode doesn't work
    # Returns google place response
    def self.search(search_text)
      # Format: https://maps.googleapis.com/maps/api/place/textsearch/json?parameters
      api_key = 'INSERT_API_KEY_HERE'
      query_text = search_text.parameterize
      language = 'en'

      return HTTParty.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query_text}&language=#{language}&key=#{api_key}")
    end

    # Docs: https://developers.google.com/places/web-service/details#PlaceDetailsRequests
    # Returns the response of place details request
    def self.details(google_place_id)
      api_key = 'INSERT_API_KEY_HERE'
      # Format: https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key=YOUR_API_KEY

      return HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{google_place_id}&key=#{api_key}")
    end

    # Performs a search request on the text, takes out the google place id of the first result, then performs a details request
    # returns response form details request, or false if it failed
    def self.details_search(search_text)
      response = GooglePlaces.search(search_text)
      return response['status'] unless response['status'] == 'OK'
      place_id = response['results'][0]['place_id'] if response['results'][0]
      return GooglePlaces.details(place_id) if place_id
      return false
    end

    # after details search, access website like response['result']['url']
    def self.get_website(search_text)
      response = self.details_search(search_text)

      return response['result']['website']
    end

    # gets photo details given a photo reference id
    # docs: https://maps.googleapis.com/maps/api/place/photo?
    # returns a url to the actual photo
    # example photo reference: CoQBdwAAAMuzSX43uGwYrSHXXE3oqakLoMnlGhI9iK-aaF6GDAK2wFCF7Uq6LgprjmR1cGBepN76QCFMDyjPhBGBVhHfQb2GG-5we94riwENKR7NbsNWf1V86CjGAjuE3R_myknk251anj6Yt0Ojfecf_uR2f1MIajbzUQxcZ9dZt7WQ9ZQtEhBN4vH_Wstt0gpp7S0cUtx1GhTPXVT2mU3ai3xB7V2WWaR5sLpj_g
    def self.photo_details(photo_reference, max_width = 1600)
      # ex. https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=YOUR_API_KEY
      api_key = 'INSERT_API_KEY_HERE'
      query = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=#{max_width}&photoreference=#{photo_reference}&key=#{api_key}"

      return query
    end
  end

  class Google
    # geocode address, returns lat/lng
    # docs: https://developers.google.com/maps/documentation/geocoding/intro#GeocodingRequests
    def self.geocode(address)
      api_key = 'INSERT_API_KEY_HERE'
      result =  HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address.parameterize}&key=#{api_key}")
      return result['status'] unless result['status'] == 'OK'
      return result['results'][0]['geometry']['location']
    end

    # given lat, lng, returns the place info
    # docs: https://developers.google.com/maps/documentation/geocoding/intro#reverse-example
    def self.reverse_geocode(lat, lng, result_type = '')
      # example query: https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY
      api_key = 'INSERT_API_KEY_HERE'
      url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{api_key}&language=en"
      url += "&result_type=#{result_type}" if result_type

      return HTTParty.get(url)
    end

    # NOTE: use CARL's HAVERSINE DISTANCE FOR FREE
    # distance search, see: https://developers.google.com/maps/documentation/distance-matrix/intro#DistanceMatrixResponses
    # can access response distance like: response['rows'][0]['elements'][0]['distance']['value'], has 3 decimal places without a period
    # e.g. 400012 is actually 400 KM, cut off last 3 like response['rows'][0]['elements'][0]['distance']['value'].to_s[0...-3]
    def self.distance(origin_place_id, destination_place_id)
      api_key = 'INSERT_API_KEY_HERE'
      # unit = 'metric' # could also be imperial
      query = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=place_id:#{origin_place_id}&destinations=place_id:#{destination_place_id}&key=#{api_key}"

      return HTTParty.get(query)
    end

    # encodes a single decimal point (or lat or lng) using google's algorithm
    # see: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    def self.encode_number(number = -179.9832104)
      # Take the initial signed value e.g. -179.9832104
      # Rails.logger.debug { "Step 1: #{number}: true" }

      # Take the decimal value and multiply it by 1e5, rounding the result: -17998321
      temp_number = (number * 100000).round
      # passed = (-17998321 == temp_number)
      # Rails.logger.debug { "Step 2: #{temp_number}: #{passed}" }

      # Convert the decimal value to binary.
      # Note that a negative value must be calculated using its two's complement by inverting the binary value and adding one to the result:
      # Answer: 11111110111011010101111000001111
      temp_number = self.to_binary(temp_number)
      # passed = ("11111110111011010101111000001111" == temp_number)
      # Rails.logger.debug { "Step 3: #{temp_number}: #{passed}" }

      # Left-shift the binary value one bit:
      # 11111101110110101011110000011110
      temp_number.slice!(0)
      temp_number += '0'
      # passed = ("11111101110110101011110000011110" == temp_number)
      # Rails.logger.debug { "Step 4: #{temp_number}: #{passed}" }

      # If the original decimal value is negative, invert this encoding:
      # 00000010 00100101 01000011 11100001
      temp_number = self.flip_binary(temp_number) if number < 0
      # passed = ("00000010001001010100001111100001" == temp_number)
      # Rails.logger.debug { "Step 5: #{temp_number}: #{passed}" }

      # Break the binary value out into 5-bit chunks (starting from the right hand side):
      # ["00001","00010","01010","10000","11111","00001"]
      # ["00001", "00010", "01010", "10000", "11111", "00001"]
      temp_number = self.split_5(temp_number)
      # passed = (["00001","00010","01010","10000","11111","00001"] == temp_number)
      # Rails.logger.debug { "Step 6: #{temp_number}: #{passed}" }

      # Place the 5-bit chunks into reverse order:
      # ['00001', '11111', '10000', '01010', '00010', '00001']
      temp_number = temp_number.reverse
      # passed = (['00001', '11111', '10000', '01010', '00010', '00001'] == temp_number)
      # Rails.logger.debug { "Step 7: #{temp_number}: #{passed}" }

      # OR each value with 0x20 if another bit chunk follows
      # 100001 111111 110000 101010 100010 000001
      temp_number = self.or2x(temp_number)
      # passed = (['100001', '111111', '110000', '101010', '100010', '000001'] == temp_number)
      # Rails.logger.debug { "Step 7: #{temp_number}: #{passed}" }

      # Convert each value to decimal
      # 33 63 48 42 34 1
      temp_number = self.bin_to_dec(temp_number)
      # passed = (['33', '63', '48', '42', '34', '1'] == temp_number)
      # Rails.logger.debug { "Step 8: #{temp_number}: #{passed}" }

      # Add 63 to each value:
      # 96 126 111 105 97 64
      temp_number = self.add_63(temp_number)
      # passed = (['96', '126', '111', '105', '97', '64'] == temp_number)
      # Rails.logger.debug { "Step 9: #{temp_number}: #{passed}" }

      # Convert each value to its ASCII equivalent:
      # `~oia@
      temp_number = self.ascii(temp_number)
      # passed = ('`~oia@' == temp_number)
      # Rails.logger.debug { "Step 10: #{temp_number}: #{passed}" }

      return temp_number
    end

    # encodes a series of points and returns the entire encoded path
    # each point is an array of [lat,lng]
    def self.encode(points)
      path = ''
      prev_lat = nil
      prev_lng = nil
      points.each_with_index do |point, i|
        if i == 0 # first point, don't do offset
          path += self.encode_number(point[0]) + self.encode_number(point[1])
        else # do offset from previous point
          offset_lat = point[0] - prev_lat
          offset_lng = point[1] - prev_lng

          Rails.logger.debug { "offset_lat #{offset_lat}, path: #{self.encode_number(offset_lat)}" }
          Rails.logger.debug { "offset_lng #{offset_lng}, path: #{self.encode_number(offset_lng)}" }
          path += self.encode_number(offset_lat) + self.encode_number(offset_lng)
        end
        prev_lat = point[0]
        prev_lng = point[1]
      end

      return path
    end

    def self.to_binary(n)
      if n >= 0
        '%032b' % n
      else
        31.downto(0).map { |b| n[b] }.join
      end
    end

    # 11111101 => 000000010
    def self.flip_binary(n)
      result = ''
      n.split('').each do |c|
        if c == '0'
          result += '1'
        else # c = 1
          result += '0'
        end
      end
      return result
    end

    # adds a leading 1 to each item in the array, except the last one, add 0
    def self.or2x(n)
      ret = []
      n.each_with_index do |num, i|
        if i == (n.length - 1) # last one
          num = '0' + num
        else
          num = '1' + num
        end

        ret << num
      end
      return ret
    end

    # splits string into 5 chunks, starting from the right
    def self.split_5(n)
      n.slice!(0) # remove first char
      n.slice!(0) # remove 2nd char
      return n.chars.each_slice(5).map(&:join)
    end

    # converts each item in the array to a decimal
    def self.bin_to_dec(n)
      ret = []
      n.each do |num|
        ret << Integer("0b#{num}")
      end

      return ret
    end

    # adds 63 to each number in an array
    def self.add_63(n)
      ret = []
      n.each do |num|
        ret << num + 63
      end
      return ret
    end

    # converts decimal to ascii and combines into one string
    def self.ascii(n)
      ret = ''
      n.each do |num|
        ret += num.chr
      end
      return ret
    end
  end
end
