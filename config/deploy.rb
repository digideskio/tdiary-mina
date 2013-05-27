require 'mina/git'
require 'mina/rbenv'

set :domain, "133.242.17.37"
set :user, "hsbt"
set :deploy_to, "/home/#{user}/app/tdiary"
set :repository, 'git://github.com/tdiary/tdiary-core.git'
set :branch, 'master'

task :environment do
  invoke :'rbenv:load'
end

desc 'update shared library'
task :update_library => :environment do
  queue "cp -r #{deploy_to}/#{shared_path}/lib/* #{deploy_to}/#{current_path}/misc/lib"
  queue "cp -r #{deploy_to}/#{shared_path}/js/* #{deploy_to}/#{current_path}/js"
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :update_library
    end
  end
end
