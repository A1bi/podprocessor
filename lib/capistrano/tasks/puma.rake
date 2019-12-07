# frozen_string_literal: true

namespace :deploy do
  after :published, 'puma:reload'
end

namespace :puma do
  %i[reload restart].each do |command|
    task command do
      on roles(:app) do
        sudo :service, fetch(:puma_service_name), command
      end
    end
  end
end
