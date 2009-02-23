require RAILS_ROOT + '/vendor/plugins/stupid_background/lib/pids'
include StupidBackground::PIDS

namespace :background do
  
  desc "Starts the StupidBackground Daemon"
  task :start do
    if get_pids.any? {|process| process_running?(process)}
      puts "Stupid Background Daemon already running or not stopped " +
           "correctly. Please stop the Daemon. If you are sure, it is, " + 
           "consider to delete the PID File tmp/pids/stupid_background.pid"
    else   
      File.delete(FILE) if File.exists?(FILE)
      
      `script/runner vendor/plugins/stupid_background/lib/run_server.rb #{ENV['runner']}`
      puts "StupidBackground Daemon successfully started."
    end
  end

  desc "Stops the StupidBackground Daemon"
  task :stop do
    unless get_pids.any? {|process| process_running?(process)}
      puts "StupidBackground Daemon is not running!"
      next
    end
    pids = get_pids
    puts "Stopping #{pids.size} Daemons..."
    pids.each do |pid|
      if process_running?(pid)
        Process.kill("HUP", pid[:pid])
        i = 0
        while (i < 10 && process_running?(pid))
          sleep 0.5
          i += 1
        end
        if i >= 10
          puts "Could not stop the Daemon ##{pid[:runner]}!"
        else
          puts "Daemon ##{pid[:runner]} successfully stopped."
        end
      else
        puts "Daemon ##{pid[:runner]} was already stopped."
      end
    end
    File.delete(FILE) if File.exists? FILE
  end
  
  desc "Tells you if the StupidBackground Daemon is running or not."
  task :status do
    pids = get_pids
    unless pids.any? {|process| process_running?(process)}
      puts "StupidBackground Daemon is NOT running."
      if File.exist?(FILE)
        puts "Ooops! The PID file is still there but the process seems to be " +
             "terminated. Please check your running processes manually and " +
             "delete the PID file tmp/pids/stupid_background.pid if it's not " +
             "running any longer."
      end
    else
      pids.each do |pid|
        if process_running?(pid)
          puts "Daemon ##{pid[:runner]} running with PID #{pid[:pid]}"
        else
          puts "!!! Daemon ##{pid[:pid]} STOPPED !!!"
        end
      end
    end
  end
  
end