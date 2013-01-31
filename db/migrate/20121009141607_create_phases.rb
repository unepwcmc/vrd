class CreatePhases < ActiveRecord::Migration
  def change
    create_table :phases do |t|
      t.string :name
      t.integer :arrangement_id

      t.timestamps
    end
  end
end
