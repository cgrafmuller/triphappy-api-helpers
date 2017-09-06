# frozen_string_literal: true

module WikimediaHelper
  include HTTParty
  class Wiki
    # Searches Wikimedia for images around a (lat, lng) point
    # docs: https://www.mediawiki.org/wiki/Extension:GeoData#API
    # eg. https://en.wikipedia.org/w/api.php?action=query&list=allimages&aiprop=url|size|dimensions&format=json&ailimit=100&aifrom=bella-visa-santiago
    def self.geoimages(lat, lng, max_photos = 20, radius = 1000)
      geo_query = "https://commons.wikimedia.org/w/api.php?format=json&action=query&generator=geosearch&ggsprimary=all&ggsnamespace=6&ggsradius=#{radius}&ggscoord=#{lat}|#{lng}&ggslimit=#{max_photos}&prop=imageinfo&iilimit=1&iiprop=url&iiurlwidth=500&iiurlheight=500"
      response = HTTParty.get(geo_query)
      photo_urls = []
      response.dig('query', 'pages')&.each do |p|
        url = p.dig(1, 'imageinfo', 0, 'url')
        photo_urls << url if url
      end
      return photo_urls
    end

    # returns an array of image urls from wikimedia using search text
    # docs: https://www.mediawiki.org/wiki/Extension:GeoData#API
    # eg. https://en.wikipedia.org/w/api.php?action=query&list=allimages&aiprop=url|size|dimensions&format=json&ailimit=100&aifrom=bella-visa-santiago
    def self.images(search_text, max_photos = 20)
      query = "https://commons.wikimedia.org/w/api.php?format=json&action=query&generator=search&gsrnamespace=6&gsrsearch=#{URI.encode(search_text)}&gsrlimit=#{max_photos}&prop=imageinfo&iiprop=url&iiurlwidth=500&iiurlheight=500"
      response = HTTParty.get(query)
      photo_urls = []
      response.dig('query', 'pages')&.each do |p|
        url = p.dig(1, 'imageinfo', 0, 'thumburl')
        photo_urls << url if url
      end
      return photo_urls
    end
  end
end
