class Numeric
  def o_clock
    # TODO: Translation!
    hour = self.to_i
    raise "#{self} is not a 'clock'!" unless (0...24).include?(self)
    minute = ((self - self.to_i) * 100).to_i
    raise "#{minute} is not a minute!" unless (0...60).include?(minute)
    Time.new.end_of_day - 24.hours + hour.hours + minute.minutes
  end
end