# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121030122014) do

  create_table "action_categories", :force => true do |t|
    t.integer  "id_feed"
    t.string   "name"
    t.text     "description"
    t.integer  "arrangement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "action_categories", ["arrangement_id"], :name => "index_action_categories_on_arrangement_id"

  create_table "annual_financings", :force => true do |t|
    t.integer  "id_feed"
    t.integer  "year"
    t.float    "contribution"
    t.float    "disbursement"
    t.integer  "arrangement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "annual_financings", ["arrangement_id"], :name => "index_annual_financings_on_arrangement_id"

  create_table "arrangements", :force => true do |t|
    t.integer  "id_feed"
    t.string   "status"
    t.string   "title"
    t.text     "description"
    t.text     "objectives"
    t.string   "financing_modality"
    t.string   "financing_type"
    t.string   "original_currency"
    t.float    "usd_conversion_rate"
    t.datetime "last_published_update"
    t.integer  "period_from"
    t.integer  "period_to"
    t.integer  "profile_id"
    t.integer  "institution_id"
    t.string   "arrangement_type"
    t.integer  "phase"
    t.boolean  "fast_start_finance"
    t.text     "comments"
    t.boolean  "estimate"
    t.text     "additional_notes"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "arrangements", ["institution_id"], :name => "index_arrangements_on_institution_id"
  add_index "arrangements", ["profile_id"], :name => "index_arrangements_on_profile_id"

  create_table "beneficiary_countries", :id => false, :force => true do |t|
    t.integer "arrangement_id"
    t.integer "institution_id"
  end

  add_index "beneficiary_countries", ["arrangement_id"], :name => "index_beneficiary_countries_on_arrangement_id"
  add_index "beneficiary_countries", ["institution_id"], :name => "index_beneficiary_countries_on_institution_id"

  create_table "focal_points", :force => true do |t|
    t.integer  "id_feed"
    t.string   "name"
    t.string   "email"
    t.string   "position"
    t.string   "institution"
    t.string   "address"
    t.string   "phone"
    t.string   "fax"
    t.boolean  "preferred"
    t.integer  "profile_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "focal_points", ["profile_id"], :name => "index_focal_points_on_profile_id"

  create_table "imports", :force => true do |t|
    t.string   "date"
    t.string   "etag"
    t.string   "last_entry_id"
    t.string   "tag",           :default => "arrangements"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "institutions", :force => true do |t|
    t.integer  "id_feed"
    t.string   "acronym"
    t.string   "name"
    t.string   "iso2"
    t.string   "institution_type"
    t.string   "iso3_code"
    t.float    "forest_area"
    t.float    "forest_area_percentage"
    t.integer  "population"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "region_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "institutions", ["id_feed"], :name => "index_institutions_on_id_feed"
  add_index "institutions", ["region_id"], :name => "index_institutions_on_region_id"

  create_table "phases", :force => true do |t|
    t.string   "name"
    t.integer  "arrangement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "phases", ["arrangement_id"], :name => "index_phases_on_arrangement_id"

  create_table "profiles", :force => true do |t|
    t.integer  "id_feed"
    t.text     "background_information"
    t.text     "approaches_working_well"
    t.text     "suggestions_on_improving_approaches"
    t.text     "suggestions_on_improving_sharing_of_experiences"
    t.datetime "last_published_update"
    t.integer  "institution_id"
    t.float    "fast_start_pledge"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "profiles", ["institution_id"], :name => "index_profiles_on_institution_id"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
