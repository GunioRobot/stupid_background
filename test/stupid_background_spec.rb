class Numeric
  def hours
    self * 3600
  end
  
  def seconds
    self
  end
end

class String
  def camelize
    self.split('_').map {|p| p.capitalize}.join('')
  end
end

require 'spec'
require 'spec/mocks'
require 'stupid_background'
require '../test/fixtures/rails_root/lib/workers/test_worker'
require '../test/fixtures/rails_root/lib/workers/test_worker_one'
require '../test/fixtures/rails_root/lib/workers/test_worker_two'

describe "First Spec Test" do
  before(:each) do
    RAILS_ROOT = '../test/fixtures/rails_root'
    File.delete("#{RAILS_ROOT}/tmp/pids/stupid_background.pid")
  end
  
  it "should behave well" do
    Daemonize.should_receive(:daemonize).once
    start_time = Time.now
    
    StupidBackground::Runner.run!(:default)
    TestWorkerOne.times_ran.should be(4)
    TestWorkerOne.tester_arr.should eql([1, 5, 6])
    
    TestWorkerTwo.times_ran.should be(7)
    TestWorkerTwo.tester_arr.should eql([8, 8, 8])
    
    (Time.now - start_time).should <(9)
  end
end