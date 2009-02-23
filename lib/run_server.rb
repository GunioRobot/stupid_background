require RAILS_ROOT + '/vendor/plugins/stupid_background/lib/logger'
require 'stupid_background'

StupidBackground::Logger.environment do
  daemon_no = (ARGV.first || 'default').intern
  StupidBackground::Runner.run!(daemon_no)
end