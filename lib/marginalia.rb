gem "httparty"
require "httparty"
require "geokit"

class Marginalia
  include HTTParty
  include Geokit
  base_uri 'en.wikipedia.org'
  default_options = {:headers => {'User-Agent' => 'Marginalia - Wikipedia context analysis: marginalia.media.mit.edu'}}
    
  # http://en.wikipedia.org/w/api.php?action=query&prop=revisions&titles=Betsy_McCaughey&rvprop=size|timestamp|user|comment|ids|flags&rvlimit=500
  def self.history(title,size = 500)
    options = { :titles => title, 
                :action => 'query',
                :prop => 'revisions',
                :rvprop => 'size|timestamp|user|comment|ids|flags',
                :rvlimit => size,
                :format => 'xml',
                :redirects => true}
    document = self.get('/w/api.php', :query => options, :options => { "User-Agent" => "Marginalia" })
  end
  
  def self.revisions(title,size = 500,diff = false)
    options = { :titles => title, 
                :action => 'query',
                :prop => 'revisions',
                :rvprop => 'size|timestamp|user|comment|ids|flags',
                :rvlimit => size,
                :format => 'xml',
                :redirects => true}
	if diff
		options[:rvdiffto] = 'prev'
	end
    document = self.get('/w/api.php', :query => options)
    document['api']['query']['pages']['page']['revisions']['rev']
  end
  
  def self.diff(title)
      revisions = Marginalia.revisions(title,500,true)
	  diffs = []
	  notcached = 0
      puts revisions.length.to_s + ' revisions'

      revisions.each do |rev|
		if rev['diff']['notcached']
			notcached += 1
		end
		unless rev['diff'].nil? || rev['diff']['notcached']
			# process revisions into hashes of diffs
			
			#puts rev['user'] + ' ' + rev['timestamp'] + ' ' + rev['diff']
			doc = REXML::Document.new('<table>' << rev['diff'].to_s << '</table>') #make an xml-ish doc out of the diff so we can traverse it
			
			# get the id of the edit
			meta = doc.elements.to_a("/table").last.comments().last
			unless meta.nil?
				edit_id = doc.elements.to_a("/table").last.comments().last.string[/oldid:([0-9]*):/,1]
			end
			# create a dictionary for each piece of added content
			addedlines = doc.elements.to_a("/table/tr/td[@class='diff-addedline']/div")
			if addedlines.empty?
				# nothing added; add flag for other change types? ie deleted
			else
				addedlines.each do |addedline|
					changedtext = String.new
					addedtexts = []
					
					addedline.children.each do |e|
						# string together the diffed text
						if e.instance_of?REXML::Element
							changedtext << e.text().to_s
							addedtexts << e.text().to_s
						else
							changedtext << e.to_s
						end
					end
					if addedtexts.empty?
						addedtexts << changedtext unless changedtext.empty?
					end
					#puts 'text: '+changedtext
					#puts 'adds: '+ addedtexts.join(',')
					
					unless addedtexts.empty?	# create a hash and add it to the diffs array
						diffs << { :author => rev['user'],
								   :id => edit_id,
								   :timestamp => Time.xmlschema(rev['timestamp']).to_i,		#convert ISO8601 string to seconds since 1970
								   :text => changedtext,
								   :adds =>  addedtexts}
					end
				end
				#puts diffs.inspect
				#puts '-------'
			end
		end

      end
      puts diffs.length.to_s + ' adds, ' + notcached.to_s + ' not cached'
	  
      diffs
  end


  def self.authors(title,diff = false)
      revisions = Marginalia.revisions(title,500,diff)
      authors = []
	  diffs = []
      puts revisions.length.to_s + ' revisions'

      revisions.each do |rev|
		unless rev['diff'].nil? || rev['diff']['notcached'] || !diff
			# process revisions into hashes of diffs
			
			#puts rev['user'] + ' ' + rev['timestamp'] + ' ' + rev['diff']
			doc = REXML::Document.new('<table>' << rev['diff'].to_s << '</table>') #make an xml-ish doc out of the diff so we can traverse it
			
			# create a dictionary for each piece of added content
			addedlines = doc.elements.to_a("/table/tr/td[@class='diff-addedline']/div")
			if addedlines.empty?
				# nothing added; add flag for other change types? ie deleted
			else
				addedlines.each do |addedline|
					changedtext = String.new
					addedtexts = []
					
					addedline.children.each do |e|
						# string together the diffed text
						if e.instance_of?REXML::Element
							changedtext << e.text().to_s
							addedtexts << e.text().to_s
						else
							changedtext << e.to_s
						end
					end
					if addedtexts.empty?
						addedtexts << changedtext unless changedtext.empty?
					end
					#puts 'text: '+changedtext
					#puts 'adds: '+ addedtexts.join(',')
					
					unless addedtexts.empty?	# create a hash and add it to the diffs array
						diffs << { :author => rev['user'],
								   :timestamp => rev['timestamp'],
								   :text => changedtext,
								   :adds =>  addedtexts}
					end
				end
				puts diffs.inspect
				puts '-------'
			end
		end

		# remove duplicate authors, tally by author, flag anonymous users
      	dupe = authors.find { |auth| ['user'] and auth['user'] == rev['user'] }
      	if dupe
      		dupe['revs'] += 1
      	else
      		authors << {'user' => rev['user'], 'anon' => rev.has_key?('anon'), 'type' => rev.has_key?('anon') ? 'anon' : '', 'revs' => 1}
      	end
      end
      puts diffs.length.to_s + ' adds'
      
	  
      authors = authors.sort { |a,b| b['revs']<=>a['revs'] }


	  # get author info from non-anon users (getting it for all accounts in one call)
	  public_authors = authors.select { |a| !a['anon'] }
	  author_names = public_authors.collect { |a| a['user'] }
	  
	  self.authors_info( author_names.join('|') ).each do |a|
	  	author = authors.select { |author| author['user'] == a['name'] }.first

      # bots break this code!!
      begin
  	  	author['editcount'] = a['editcount']
  	  	if a['groups']
  	  		if a['groups']['g'].include?('bot')
  	  			author['bot'] = true
  	  		end
    			if a['groups']['g'].include?('sysop')
    				author['sysop'] = true
    			end
  	  	end
      rescue
        puts "something broke. Maybe a bot. couldn't find a author['user'] == a['name']"
      end
	  end
	  

      # geocode authors
	  #self.author_locations(authors)

      authors
  end

  # &list=users&ususers=brion|TimStarling&usprop=groups|editcount|gender
  def self.authors_info(usernames)
    options = { :ususers => usernames, 
                :action => 'query',
                :list => 'users',
                :format => 'xml',
                :usprop => 'blockinfo|registration|emailable|groups|editcount|gender'}
    document = self.get('/w/api.php', :query => options)
    document['api']['query']['users']['user']
  end
  
  # http://en.wikipedia.org/w/api.php?action=query&list=usercontribs&ucuser=YurikBot
  # returns a list of recent edits
  def self.author_edits(username,num = 500)
    options = { :ucuser => username,
                :uclimit => num,
                :action => 'query',
                :list => 'usercontribs',
                :format => 'xml',
                :ucprop => 'ids|title|timestamp|comment|size|flags'}
    document = self.get('/w/api.php', :query => options)
    document['api']['query']['usercontribs']['item']
  end

  # geocode authors
  def self.author_locations(authors)
	  authors[0..19].each do |author|
		if author['anon']
		  begin
			# <a href="http://www.geoplugin.com/" target="_new" title="geoPlugin for IP geolocation">Geolocation by geoPlugin</a>
			#puts 'geocoding: '+author['user']
			location = Geokit::Geocoders::GeoPluginGeocoder.geocode(author['user'])
			if location.city == 'N/A' && location.state == 'N/A'
				author['location'] = location.country_code
			else
				author['location'] = location.city+', '+location.state+' ('+location.country_code+')'
			end
		  # rescue
		  #   puts 'failed to geocode anonymous user'
		  end
		else
		  # find via user information?
		end
	  end
  end
  
  def self.author_location(ip)
	# <a href="http://www.geoplugin.com/" target="_new" title="geoPlugin for IP geolocation">Geolocation by geoPlugin</a>
	ip.tr!('-','.')
	puts 'geocoding: '+ip
	location = Geokit::Geocoders::GeoPluginGeocoder.geocode(ip)
	if location == nil
		return nil
	elsif location.city == 'N/A' && location.state == 'N/A'
		return location.country_code
	else
		return location.city+', '+location.state+' ('+location.country_code+')'
	end
  end
    
end
