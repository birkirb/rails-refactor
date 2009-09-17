require 'optparse'
require 'processor'

begin
  options = {:scm => true, :migrate => false, :execute => false}
  option_parser = OptionParser.new do |opts|
    opts.program_name = "script/refactor"
    opts.version = "(version 0.1)"
    opts.banner = "Usage: #{opts.program_name} [OPTIONS] [COMMANDS]"
    opts.separator ""
    opts.separator "COMMANDS:"
    opts.separator "  rename [old_class_name] [new_class_name]"
    opts.separator ""
    opts.separator "OPTIONS:"
    opts.on("-x", "--[no-]execute", "Execute supplied commands. Must be supplied to run otherwise it will just show what would have been done.") { |b| options[:execute] = b }
    opts.on("-h", "--help", "This help message.") { |b| options[:help] = b }
    opts.on("-s", "--[no-]use-scm", "Use SCM support.") { |b| options[:scm] = b }
    opts.on("-m", "--[no-]migrations", "Generate migrations.") { |b| options[:migrate] = b }
    opts.on("-f", "--command-file COMMAND_FILE", "Read commands from file.") { |file| options[:file] = file }
    opts.separator ""
    opts.separator "Examples:"
    opts.separator "  #{opts.program_name} rename parasite user"
  end
  option_parser.parse!(ARGV)

  if options[:help]
    puts option_parser
  else
    processor = RailsRefactor::Processor.new(options)

    if file = options[:file]
      processor.file_commands(file)
    end

    if option_parser.default_argv.size > 0
      processor.command_line(option_parser.default_argv)
    end
  end
rescue => err
  puts err.message
  puts err.backtrace
  puts option_parser
end
