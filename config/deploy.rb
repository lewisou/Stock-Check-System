require 'bundler/capistrano'
set :application, "scs"
set :repository,  "git@wordcare.me:scs"
set :branch, "master"

set :scm, :git

set :deploy_to, "/var/www/apps/#{application}"

set :user, "www-data"
set :use_sudo, false
ssh_options[:forward_agent] = true

role :web, "192.168.1.203"                          # Your HTTP server, Apache/etc
role :app, "192.168.1.203"                          # This may be the same as your `Web` server
role :db,  "192.168.1.203", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

desc "Make symlink for database yaml" 
namespace :db do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", "db:symlink"
