require 'optparse'
require 'processor'

begin
  options = {:scm => true, :migrate => false, :execute => false}
  option_parser = OptionParser.new do |opts|
    opts.program_name = "script/refactor"
    opts.version = "(version 0.1)"
    opts.banner = "Usage: #{opts.program_name} [OPTIONS] [COMMANDS]"
    opts.separator ""
    opts.separator "OPTIONS:"
    opts.on("-h", "--help", "This help message.") { |b| options[:help] = b }
    opts.on("-f", "--command-file COMMAND_FILE", "Read commands from file.") { |file| options[:file] = file }
    opts.on("-s", "--[no-]use-scm", "Use SCM support.") { |b| options[:scm] = b }
    opts.separator ""
    opts.separator "COMMANDS:"
  end

  option_parser.parse!(ARGV)
  processor = RailsRefactor::Processor.new(option_parser)

  if options[:help]
    puts option_parser
  else
    if file = options[:file]
      processor.file_commands(file)
    end

    if option_parser.default_argv.size > 0
      processor.command_line(option_parser.default_argv, options)
    end
  end
rescue => err
  puts err.message
  puts err.backtrace
  puts option_parser
end
