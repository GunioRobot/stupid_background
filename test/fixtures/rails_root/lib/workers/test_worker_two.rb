class TestWorkerTwo < TestWorker
  
  call(:test).every(2.seconds).with(2,3,4)
  call(:test).every(1.seconds).with(8,8,8)
  call(:test_two).every(1.seconds)
  
  def test(a,b,c)
    self.class.tester_arr = [a, b, c]
    self.class.times_ran = (self.class.times_ran || 0) + 1
    stop_job! if self.class.times_ran > 5
  end
  
  def test_two
    self.class.times_ran = (self.class.times_ran || 0) + 1
    stop_job!
  end

end