require "fileutils"
script_name = File.join('script', 'refactor')
puts "          rm  #{script_name}"
FileUtils.rm script_name
