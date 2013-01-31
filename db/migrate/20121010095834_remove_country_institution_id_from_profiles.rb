class RemoveCountryInstitutionIdFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :country_institution_id
  end

  def down
    add_column :profiles, :country_institution_id, :integer
  end
end
