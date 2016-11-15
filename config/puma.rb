# frozen_string_literal: true
#
DEV_PORT = 'GA'.each_byte.reduce('') { |a, e| a + format('%x', e) }.to_i
workers Integer(ENV['PUMA_WORKERS'] || 4)
threads Integer(ENV['MIN_THREADS'] || 8),
        Integer(ENV['MAX_THREADS'] || 32)

preload_app!

rackup DefaultRackup
port ENV['PORT'] || DEV_PORT
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    config =
      ActiveRecord::Base.configurations[Rails.env] ||
      Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end
