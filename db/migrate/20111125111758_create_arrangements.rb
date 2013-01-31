class CreateArrangements < ActiveRecord::Migration
  def change
    create_table :arrangements do |t|
      t.integer :id_feed
      t.string :status
      t.string :title
      t.text :description
      t.text :objectives
      t.string :financing_modality
      t.string :financing_type
      t.string :original_currency
      t.float :usd_conversion_rate
      t.timestamp :last_published_update
      t.integer :period_from
      t.integer :period_to

      t.integer :profile_id
      t.integer :institution_id
      t.string :arrangement_type
      t.integer :phase
      t.boolean :fast_start_finance
      t.text :comments
      t.boolean :estimate
      t.text :additional_notes

      t.timestamps
    end
  end
end
