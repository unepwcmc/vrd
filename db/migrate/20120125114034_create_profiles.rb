class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :id_feed
      t.text :background_information
      t.text :approaches_working_well
      t.text :suggestions_on_improving_approaches
      t.text :suggestions_on_improving_sharing_of_experiences
      t.integer :country_institution_id
      t.datetime :last_published_update
      t.integer :institution_id
      t.float :fast_start_pledge

      t.timestamps
    end
  end
end
