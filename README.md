# Random Ruby Impementations of External APIs

Below are some implementation of APIs used on  https://triphappy.com

* Yahoo Finance
* Flickr
* Google Javascript API
* Imagemagick
* Wikimedia
* Free GeoIP

## Getting Started

* Install [HTTParty gem](https://github.com/jnunemaker/httparty)
* Copy your desired helper into App > Assets > Helpers
* Change ``` 'INSERT_API_KEY_HERE' ``` to your API key, preferably using environment variables
* Enjoy

## Example Usage

```
Running via Spring preloader in process 10998
Loading development environment (Rails 4.2.8)
2.4.1 :001 > include GoogleHelper
 => Object
2.4.1 :002 > response = GooglePlaces.search('Bangkok')
2.4.1 :003 > response['results'][0]['place_id']
 => "ChIJ82ENKDJgHTERIEjiXbIAAQE"
```
