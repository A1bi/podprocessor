# frozen_string_literal: true

namespace :deploy do
  after :starting, 'sidekiq:silence'
  after :updated, 'sidekiq:stop'
  after :published, 'sidekiq:start'
  after :failed, 'sidekiq:restart'
end

namespace :sidekiq do
  %i[start stop restart silence].each do |command|
    task command do
      on roles(:app) do
        sudo :service, fetch(:sidekiq_service_name), command,
             raise_on_non_zero_exit: %i[start restart].include?(command)
      end
    end
  end
end
