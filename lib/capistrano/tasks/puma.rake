# frozen_string_literal: true

namespace :deploy do
  after :published, 'puma:reload'
end

namespace :puma do
  %i[reload restart].each do |command|
    task command do
      on roles(:app) do
        sudo :service, fetch(:puma_service_name), command
      rescue StandardError => e
        # in case puma hasn't been running yet reload will fail
        raise e unless command == :reload

        sudo :service, fetch(:puma_service_name), :start
      end
    end
  end
end
