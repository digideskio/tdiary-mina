require 'mina/git'
require 'mina/bundler'
require 'mina/rbenv'

set :domain, "www.hsbt.org"
set :user, "hsbt"
set :deploy_to, "/home/#{user}/app/tdiary"
set :repository, 'git://github.com/tdiary/tdiary-core.git'
set :branch, 'master'

task :environment do
  invoke :'rbenv:load'
end

task :copy_assets do
  queue "cp -r #{deploy_to}/#{shared_path}/lib/* #{deploy_to}/#{current_path}/misc/lib"
  queue "cp -r #{deploy_to}/#{shared_path}/js/* #{deploy_to}/#{current_path}/js"
  queue "sudo cp -r #{deploy_to}/#{current_path}/theme/* /var/www/hsbt.org/diary/theme"
end

task :generate_gemfile_local do
  queue "echo \"gem 'tdiary-style-gfm'\" > #{deploy_to}/#{current_path}/Gemfile.local"
end

task :restart do
  queue 'sudo /etc/init.d/apache2 restart'
end

task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :generate_gemfile_local
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :copy_assets
    end
  end
end
