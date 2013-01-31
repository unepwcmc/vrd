class AddIndexes < ActiveRecord::Migration
  def change
    add_index :action_categories, :arrangement_id
    add_index :annual_financings, :arrangement_id
    add_index :arrangements, :profile_id
    add_index :arrangements, :institution_id
    add_index :beneficiary_countries, :arrangement_id
    add_index :beneficiary_countries, :institution_id
    add_index :focal_points, :profile_id
    add_index :institutions, :region_id
    add_index :phases, :arrangement_id
    add_index :profiles, :institution_id
  end
end
