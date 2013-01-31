class CreateActionCategories < ActiveRecord::Migration
  def change
    create_table :action_categories do |t|
      t.integer :id_feed
      t.string :name
      t.text :description
      t.integer :arrangement_id

      t.timestamps
    end
  end
end
