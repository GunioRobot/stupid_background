module StupidBackground
  module PIDS
    FILE = "#{RAILS_ROOT}/tmp/pids/stupid_background.pid"
    
    def get_pids
      pids = Array.new
      begin
        File.open(FILE, 'r') do |file|
          while !file.eof?
            line_parts = file.gets.split(' ')
            pids << {:pid => line_parts.first.to_i, :runner => line_parts.last}
          end
        end
      rescue Errno::ENOENT => e
        #There is no PID file, but this is ok, we're just passing back the empty array.
      end
      pids
    end
    
    def remove_pid(daemon_name)
      daemon_name = daemon_name.to_s.strip
      lines = []
      begin
        File.open(FILE, 'r') do |file|
          while !file.eof?
            line = file.gets
            line_parts = line.split(' ')
            lines << line unless line_parts.last.strip == daemon_name
          end
        end
      rescue Errno::ENOENT => e
        #There is no PID file, but this is ok, we're just passing back the empty array.
      end
      File.open(FILE, 'w') do |file|
        lines.each do |line|
          file.puts line
        end
      end
    end
    
    def add_pid(pid, daemon_name)
      File.open FILE, 'a' do |file|
        file.puts "#{pid} #{daemon_name}"
      end
    end
    
    def update_pid(pid, daemon_name)
      remove_pid(daemon_name)
      add_pid(pid, daemon_name)
    end

    def process_running?(pid)
      return false unless pid

      begin
        Process.getpgid(pid[:pid])
      rescue Errno::ESRCH => e
        return false if e.to_s == "No such process"
        raise "Some strange things happened! This is probably a bug. So if you " +
             "think it is, please file a bug report to bugs@fetmab.net. ErrCode: 1."
      end
      true
    end
  end
end