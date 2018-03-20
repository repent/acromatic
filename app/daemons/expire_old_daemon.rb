require 'daemons'

# run using
#   ruby app/daemons/expire_old_daemon.rb start
# also availablu:
#  stop
#  run (runs in the foreground for debugging)
#  restart

ENV["APP_ROOT"] ||= File.expand_path("#{File.dirname(__FILE__)}/..")

Daemons.run "#{ENV['APP_ROOT']}/daemons/expire_old.rb"