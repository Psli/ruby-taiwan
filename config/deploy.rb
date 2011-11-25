# coding: utf-8
require './config/boot'
require 'airbrake/capistrano'
require "airbrake/capistrano"
default_environment["RAILS_ENV"] = "production"
default_environment["PATH"] = "/usr/local/bin:/usr/bin:/bin"

set :application, "ruby-taiwan"
set :repository,  "git://github.com/xdite/ruby-taiwan.git"
set :branch, "production"
set :scm, :git
set :user, "apps"
set :deploy_to, "/home/apps/#{application}"
set :runner, "apps"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

role :web, "ruby-taiwan.org"                          # Your HTTP server, Apache/etc
role :app, "ruby-taiwan.org"                          # This may be the same as your `Web` server
role :db,  "ruby-taiwan.org", :primary => true # This is where Rails migrations will run

namespace :deploy do

  desc "Restart passenger process"
  task :restart, :roles => [:web], :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


task :init_shared_path, :roles => :web do
  run "mkdir -p #{deploy_to}/shared/log"
  run "mkdir -p #{deploy_to}/shared/pids"
end

task :link_shared_config_yaml, :roles => :web do
  run "ln -sf #{deploy_to}/shared/config/*.yml #{deploy_to}/current/config/"
end

task :restart_resque, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
end

# 编译 assets
task :compile_assets, :roles => :web do
  run "cd #{deploy_to}/current/; bundle exec rake assets:precompile"
end

after "deploy:symlink", :init_shared_path, :link_shared_config_yaml , :compile_assets



