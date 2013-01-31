class CreateBeneficiaryCountries < ActiveRecord::Migration
  def change
    create_table :beneficiary_countries, :id => false do |t|
      t.integer :arrangement_id
      t.integer :institution_id
    end
  end
end
