listen '127.0.0.1:4567'
preload_app false
timeout 10

if ENV['RAILS_ENV'] == 'production'
  worker_processes 2
  pid 'tmp/unicorn.pid'

  log_path =  '/var/unicorn_logs/log.txt'
  stderr_path log_path 
  stdout_path log_path 
end
