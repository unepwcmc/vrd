class CreateFocalPoints < ActiveRecord::Migration
  def change
    create_table :focal_points do |t|
      t.integer :id_feed
      t.string :name
      t.string :email
      t.string :position
      t.string :institution
      t.string :address
      t.string :phone
      t.string :fax
      t.boolean :preferred
      t.integer :profile_id

      t.timestamps
    end
  end
end
