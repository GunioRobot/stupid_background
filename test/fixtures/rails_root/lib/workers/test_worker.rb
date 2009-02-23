class TestWorker < StupidBackground::Worker
  def self.initialize
    @times_ran = 0
    @tester_arr = []
  end
  
  def self.times_ran=(times_ran)
    @times_ran = times_ran
  end
  
  def self.times_ran
    @times_ran
  end
  
  def self.tester_arr=(arr)
    @tester_arr = arr
  end
  
  def self.tester_arr
    @tester_arr
  end
end