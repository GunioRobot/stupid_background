module StupidBackground
  class Logger
    def self.environment
      # reset the STDOUT to a logfile where all running processes are writing to
      log_file = File.open("#{RAILS_ROOT}/log/stupid_background.log", 'a')
      $stdout = log_file.to_io
      $stderr = log_file.to_io

      yield

      # reset the STDOUT and STDERR to the default
      $stdout = STDOUT
      $stderr = STDERR
      log_file.close
    end
  end
end