# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'podprocessor'
set :repo_url, 'git@gitlab.a0s.de:albrecht/podprocessor.git'
set :deploy_to, '/home/sinatra/podprocessor'

append :linked_files, '.env'
append :linked_dirs, 'tmp/pids', 'tmp/sockets', 'log', '.bundle'

set :keep_releases, 2

set :puma_service_name, 'podprocessor_web'
set :sidekiq_service_name, 'podprocessor_worker'
