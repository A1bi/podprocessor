# frozen_string_literal: true

bind "tcp://[::]:#{ENV.fetch('PORT', 3000)}"
