# frozen_string_literal: true

require 'dotenv/load'

require_relative '../app'

Pony.options = {
  via: :smtp,
  via_options: {
    address: 'smtp.a0s.de',
    port: 587,
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: :plain
  }
}
