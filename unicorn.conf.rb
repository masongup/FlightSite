listen '127.0.0.1:4567'
preload_app false
worker_processes 2
timeout 10

log_path =  '../unicorn_logs/log.txt'
stderr_path log_path 
stdout_path log_path 
