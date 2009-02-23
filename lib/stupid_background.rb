require 'yaml'
require 'daemonize'
require 'find'
require 'pids'
require 'pathname'
require 'clock_enhancement'

include StupidBackground::PIDS

module StupidBackground
  class Worker
    attr_writer :arguments
    attr_accessor :interval, :time_last_ran
    
    def initialize(method)
      @method = method
      @time_last_ran = Time.now
    end
    
    def needs_to_be_run?
      return nil unless @interval
      Time.now > @time_last_ran + @interval
    end
    
    def run
      if @arguments
        self.send(@method, *@arguments) if needs_to_be_run?
      else
        self.send(@method) if needs_to_be_run?
      end
      @time_last_ran = Time.now
    end
    
    def next_run
      return nil unless @interval
      @time_last_ran + @interval
    end

    def self.call(method)
      @tasks_list ||= Array.new
      @tasks_list << Task.new(self,method)
      @tasks_list.last
    end
    
    def self.use_runner(runner_name)
      @runner = runner_name.to_sym
    end
    
    def self.runner
      @runner ||= :default
      @runner
    end
    
    def self.needs_to_be_run?
      return false unless @tasks_list
      @tasks_list.each do |task|
        return true if task.worker.needs_to_be_run?
      end
    end
    
    def self.run
      return unless @tasks_list
      @tasks_list.each do |task|
        task.worker.run if task.worker.needs_to_be_run?
      end
    end
    
    def self.next_run
      return nil unless @tasks_list      
      next_run = nil
      @tasks_list.each do |task|
        next_run = task.worker.next_run if task.worker.next_run && (!next_run || next_run > task.worker.next_run)  
      end
      next_run
    end
    
    private
    
    def logger
      RAILS_DEFAULT_LOGGER
    end
    
    def stop_job!
      @interval = nil
    end
  end
  
  class Task
    attr_reader :worker

    def initialize(clazz, method)
      @worker = clazz.new(method)
    end

    def every(interval)
      @worker.time_last_ran -=  interval.to_f if @first_run_set_by_user
      @worker.interval = interval
      self
    end

    def with(*args)
      @worker.arguments = args
      self
    end
    
    def at(time)
      first_run = time
      first_run = first_run + 24.hours if Time.now > first_run
      @worker.time_last_ran = first_run
      @first_run_set_by_user = true
      self
    end
    
    def and_run
      self
    end
  end
  
  
  class Runner
    
    def self.run!(daemon_name)
      Daemonize.daemonize
      update_pid(Process.pid, daemon_name)
      
      load_workers!(daemon_name)
      while(true)
        next_run =  nil
        
        @jobs.each do |worker|
          worker.run
          if worker.next_run && worker.next_run < (next_run || Time.now + 24.hours)
            next_run = worker.next_run
          end
        end

        break unless next_run
        sleep_time = (next_run - Time.now).to_i

        $stdout.flush
        sleep sleep_time > 1 ? sleep_time : 1
      end
    end
  
    private
  
    def self.load_workers!(daemon_name)
      @jobs     = Array.new
      @runners  = Hash.new
      Find.find("#{RAILS_ROOT}/lib/workers") do |file| 
        next unless file[-3..-1] == ".rb"
        basename = Pathname.new(file).basename.to_s
        worker = init_worker(basename[0..-4])
        if worker.runner == daemon_name
          @jobs << worker  
        else
          if daemon_name == :default && !@runners[worker.runner]
            `#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/vendor/plugins/stupid_background/lib/run_server.rb #{worker.runner}`
            @runners[worker.runner] = true
          end
        end
        
      end
    end
    
    def self.init_worker(class_name)
      require "#{RAILS_ROOT}/lib/workers/#{class_name}"
      clazz = Kernel.const_get(class_name.camelize)
    end
    
  end
end
