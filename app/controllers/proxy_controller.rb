require 'json'
class ProxyController < ApplicationController
  caches_page :ip_geocode
  
  def article
    params[:url] = 'http://en.wikipedia.org/wiki/'+params[:title] if params[:title]
    params[:title] ||= params[:url].split('/').last

    # geocode article:
    geonames = Geonames.wikipedia(params[:title])
    unless geonames['geonames'] == []
      @location = {:lon => geonames['geonames'].first['lng'],:lat => geonames['geonames'].first['lat']}
    end

    url = URI.parse(params[:url])
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    @title = params[:title]
    @body = res.body.gsub('</body></html>','')
    
    # <link rel="stylesheet" href="/skins-1.5/common/shared.css?239az2" type="text/css" media="screen" />
    @body = @body.gsub(/<link .* \/>/,'')
    # <script src="/skins-1.5/common/wikibits.js?urid=239az2" type="text/javascript"></script>
    @body = @body.gsub(/<script.*<\/script>/,'')
    @body = @body.gsub(/<img.*skins-1\.5.*\.png.*\/>/,'')
    @body = @body.gsub(/<img.*wikimedia-button\.png.*\/>/,'')
  end
  
  # freegeoip returns:
  # {"status":true,
  # "ip":"129.55.200.20",
  # "countrycode":"US",
  # "countryname":"United States",
  # "regioncode":"MA",
  # "regionname":"Massachusetts",
  # "city":"Lexington",
  # "zipcode":"",
  # "latitude":42.4501,
  # "longitude":-71.2248}  
  def ip_geocode
    ip = params[:ip1]+'.'+params[:ip2]+'.'+params[:ip3]+'.'+params[:ip4]
    location = Location.find_by_ip(ip)
    unless location
      puts 'getting new location for '+ip.to_s
      url = 'http://freegeoip.appspot.com/json/'+ip
      url = URI.parse(url)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      location_obj = JSON.parse(res.body)
    
      location = Location.new({
        :ip => ip,
        :countryname => location_obj['countryname'],
        :regionname => location_obj['regionname'],
        :city => location_obj['city'],
        :zipcode => location_obj['zipcode'],
        :lat => location_obj['latitude'],
        :lon => location_obj['longitude']
      })
      location.save
    else
      puts 'cached location'
    end
    render :json => location
  end

end
