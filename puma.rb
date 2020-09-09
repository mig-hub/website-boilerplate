threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

port ENV['PORT'] || 8080

environment ENV['RACK_ENV'] || 'development'

workers_count = Integer(ENV['WEB_CONCURRENCY'] || 2)

if workers_count > 1
  preload_app!
  workers workers_count
end

before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.enable_rolling_restart # Default is every 6 hours

  $mongoclient.close
end

on_worker_boot do
  $mongoclient.reconnect
end

