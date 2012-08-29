set :application, "robbie"
set :repository,  "https://github.com/thattommyhall/robbie.coffee"
set :repository_cache,    "#{application}_cache"
set :environment,         "production"
set :use_sudo, true
set :runner,              "ubuntu"
set :user,                "ubuntu"
set :scm_user,            "ubuntu"
set :deploy_to,           "/var/www/#{application}"
set :keep_releases,       5
set :deploy_via,          :remote_cache
set :scm,                 :git

role :web, "109.107.37.65"

after 'deploy:setup', :custom_setup, :update_upstart

task :custom_setup do
  sudo "chown -R ubuntu:ubuntu #{deploy_to}"
  sudo "add-apt-repository ppa:chris-lea/node.js"
  sudo "apt-get update"
  sudo "apt-get install -y --force-yes git nodejs nodejs-dev build-essential npm"
  sudo "npm install -g coffee-script"
end

task :update_upstart do
  put File.read(File.join(File.dirname(__FILE__), 'robbie-upstart')), '/tmp/robbie-upstart', :mode => '644'
  sudo "mv -f /tmp/robbie-upstart /etc/init/robbie.conf"
end

after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :restart do
    sudo "stop robbie;true"
    sudo "start robbie"
  end
end
