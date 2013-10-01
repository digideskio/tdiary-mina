require 'mina/git'
require 'mina/rbenv'

set :domain, "www.hsbt.org"
set :user, "hsbt"
set :deploy_to, "/home/#{user}/app/tdiary"
set :repository, 'git://github.com/tdiary/tdiary-core.git'
set :branch, 'master'

task :environment do
  invoke :'rbenv:load'
end

task :copy_assets => :environment do
  queue "cp -r #{deploy_to}/#{shared_path}/lib/* #{deploy_to}/#{current_path}/misc/lib"
  queue "cp -r #{deploy_to}/#{shared_path}/js/* #{deploy_to}/#{current_path}/js"
  queue "sudo cp -r #{deploy_to}/#{current_path}/theme/* /var/www/hsbt.org/diary/theme"
end

task :generate_gemfile_local => :environment do
  queue "echo \"gem 'tdiary-style-gfm'\" > #{deploy_to}/#{current_path}/Gemfile.local"
end

task :bundle => :environment do
  queue "cd #{deploy_to}/#{current_path}; bundle install --without development:test"
end

task :restart do
  queue 'sudo /etc/init.d/apache2 graceful'
  queue 'sudo /etc/init.d/memcached restart'
end

task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :generate_gemfile_local
      invoke :copy_assets
      invoke :bundle
      invoke :restart
    end
  end
end
