namespace :vrd do
  desc "Run all the taks in correct order"
  task :all => [:feed_institutions, :feed_profiles, :feed_arrangements, :update_cartodb, :countries_statistics, :country_coordinates, :regions_import]
end
