class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :date
      t.string :etag
      t.string :last_entry_id
      t.string :tag, default: 'arrangements'

      t.timestamps
    end
  end
end
