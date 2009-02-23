# Install hook code here
require 'fileutils'
begin
  FileUtils.mkdir 'lib/workers'
rescue Errno::EEXIST => e
end