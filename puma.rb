threads Integer(ENV['MIN_THREADS'] || 5), Integer(ENV['MAX_THREADS'] || 5)
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
preload_app!
port ENV['PORT'] || 8080
environment ENV['RACK_ENV'] || 'development'

