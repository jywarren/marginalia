# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091008195613) do

  create_table "locations", :force => true do |t|
    t.string   "ip",                                          :default => ""
    t.string   "countryname",                                 :default => ""
    t.string   "regionname",                                  :default => ""
    t.string   "city",                                        :default => ""
    t.string   "zipcode",                                     :default => ""
    t.decimal  "lat",         :precision => 20, :scale => 10, :default => 0.0
    t.decimal  "lon",         :precision => 20, :scale => 10, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
