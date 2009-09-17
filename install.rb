require "fileutils"
script_name = File.join('script', 'refactor')
puts "      create  #{script_name}"
source = File.join(File.dirname(__FILE__), "#{script_name}")
destination = script_name
FileUtils.copy(source, destination)
