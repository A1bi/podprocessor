# frozen_string_literal: true

bind "tcp://[::]:#{ENV.fetch('PORT', 3000)}"

environment ENV.fetch('APP_ENV', 'development')
