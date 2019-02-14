# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'podprocessor'
set :repo_url, 'git@gitea.dyn.a0s.de:Albrecht/podprocessor.git'
set :deploy_to, '/home/sinatra/podprocessor'

append :linked_files, '.env'
append :linked_dirs, 'tmp/pids', 'tmp/sockets', 'log'

set :keep_releases, 2

set :sidekiq_require, './app.rb'
