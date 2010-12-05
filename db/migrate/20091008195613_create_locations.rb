class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      
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
      t.string :ip, :default => ''
      t.string :countryname, :default => ''
      t.string :regionname, :default => ''
      t.string :city, :default => ''
      t.string :zipcode, :default => ''
      t.decimal  "lat", :precision => 20, :scale => 10, :default => 0.0
      t.decimal  "lon", :precision => 20, :scale => 10, :default => 0.0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
