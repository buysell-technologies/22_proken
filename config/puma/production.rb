threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Specifies the `environment` that Puma will run in.
#
environment "production"
app_root = File.expand_path("../../..", __FILE__)
bind "unix://#{app_root}/tmp/sockets/puma.sock"

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
