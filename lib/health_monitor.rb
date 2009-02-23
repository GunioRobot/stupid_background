RAILS_ROOT = '.'
$LOAD_PATH << RAILS_ROOT + '/vendor/plugins/stupid_background/lib/'

require 'pids'
require 'stupid_background'
require RAILS_ROOT + '/vendor/plugins/stupid_background/lib/logger'
include StupidBackground::PIDS

StupidBackground::Logger.environment do
  get_pids.each do |pid|
    unless process_running?(pid)
      print "Restarting: #{pid[:runner]}..."
      `script/runner vendor/plugins/stupid_background/lib/run_server.rb #{ENV['runner']}`
      puts "done."
    end
  end
end