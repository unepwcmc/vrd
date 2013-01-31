source 'http://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'execjs'
gem 'therubyracer'

gem 'httparty'

gem 'cartodb-rb-client'
gem 'leaflet-rails'

gem 'rails-backbone'

gem 'kaminari'

gem 'whenever', require: false

gem 'bootstrap-generators', '~> 2.1', git: 'git://github.com/decioferreira/bootstrap-generators.git'

group :development do
  gem 'bullet'
  gem 'railroady'

  # Deployment
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'brightbox'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'ruby-debug19', require: 'ruby-debug', group: [:test, :development]

gem 'rspec-rails', '~> 2.6', group: [:test, :development]
group :test do
  gem 'capybara'
  gem 'headless'
  gem 'database_cleaner'

  gem 'guard-rspec'
  gem 'rb-inotify', '~> 0.8.8', :require => RUBY_PLATFORM.include?('linux') && 'rb-inotify'
  gem 'rb-fsevent', '~> 0.9.1', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'

  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'launchy'
end
