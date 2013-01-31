class CreateAnnualFinancings < ActiveRecord::Migration
  def change
    create_table :annual_financings do |t|
      t.integer :id_feed
      t.integer :year
      t.float :contribution
      t.float :disbursement
      t.integer :arrangement_id

      t.timestamps
    end
  end
end
