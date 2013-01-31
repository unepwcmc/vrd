class AddIndexToInsitutionIdFeed < ActiveRecord::Migration
  def change
    add_index :institutions, :id_feed
  end
end
