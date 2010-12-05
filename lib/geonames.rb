gem "httparty"
require "httparty"
require "geokit"

class Geonames
  include HTTParty
  include Geokit
  base_uri 'ws.geonames.org'
  # http://ws.geonames.org/wikipediaSearchJSON?q=mit_media_lab&maxRows=10
	# {"geonames":[{"summary":"The Massachusetts Institute of Technology (MIT) is a private, coeducational research university located in Cambridge, Massachusetts. MIT has five schools and one college, containing 32 academic departments, with a strong emphasis on scientific and technological research. MIT is one of two private land-grant universities and is also a sea-grant and space-grant university (...)","title":"Massachusetts Institute of Technology","wikipediaUrl":"en.wikipedia.org/wiki/Massachusetts_Institute_of_Technology","elevation":0,"countryCode":"US","lng":-71.0927777777778,"feature":"landmark","thumbnailImg":"http://www.geonames.org/img/wikipedia/80000/thumb-79563-100.jpg","lang":"en","lat":42.3588888888889,"population":0}]}

  def self.wikipedia(query,size = 1)
    options = { :q => query, 
                :maxRows => size
              }
    document = self.get('/wikipediaSearchJSON', :query => options)
  end
  
end