class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.integer :id_feed
      t.string :acronym
      t.string :name
      t.string :iso2
      t.string :institution_type
      # outside the feed
      t.string :iso3_code
      t.float :forest_area
      t.float :forest_area_percentage
      t.integer :population
      t.float :latitude
      t.float :longitude

      t.integer :region_id

      t.timestamps
    end
  end
end
