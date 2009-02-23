class TestWorkerOne < TestWorker
  call(:test).every(2.seconds).with(1,5,6)
  
  def test(a,b,c)
    self.class.tester_arr = [a, b, c]
    self.class.times_ran = (self.class.times_ran || 0) + 1
    stop_job! if self.class.times_ran > 3
  end
end