# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# if ::Rails.env == 'development'
#   require 'metric_fu'
#   MetricFu::Configuration.run do |config|
#    config.rcov[:rcov_opts] << "-Itest" # Needed to find test_helper
#   end
# end

Scs::Application.load_tasks
