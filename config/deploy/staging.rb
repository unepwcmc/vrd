# Primary domain name of your application. Used in the Apache configs
set :domain, 'unepwcmc-005.vm.brightbox.net'

# List of servers
server 'unepwcmc-005.vm.brightbox.net', :app, :web, :db, :primary => true

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "vrdb"
set :rails_env, "staging"

set :branch, "development"
