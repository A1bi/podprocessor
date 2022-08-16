# frozen_string_literal: true

require 'dotenv/load'

require_relative '../app'

Pony.options = {
  via: :smtp,
  via_options: {
    address: ENV.fetch('SMTP_HOST'),
    port: ENV.fetch('SMTP_PORT', 587),
    user_name: ENV.fetch('SMTP_USERNAME', nil),
    password: ENV.fetch('SMTP_PASSWORD', nil),
    authentication: :plain
  }
}
