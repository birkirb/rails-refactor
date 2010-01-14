require 'find'
require 'rubygems'
require 'active_support'
require 'commands/base'
require 'scm/abstract'
require 'scm/file'
require 'scm/git'
require 'scm/svn'

module RailsRefactor
  class Processor

    def initialize(option_parser)
      @option_parser = option_parser
      reset
      load_commands
    end

    def file_commands(file)
      File.readlines(file).each do |line|
        command_line(line.split(' '))
      end
    end

    def command_line(args, options)
      args.each do |arg|
        if klass = @commands[arg.to_sym]
          execute if @command_klass
          @command_klass = klass
        else
          @command_args << arg
        end
      end
      execute(options)
    end

    private

    def load_commands
      require_commands
      @commands = self.class.commands_in_object_space
      @commands.each do |name, klass|
        @option_parser.separator(klass.help)
      end
    end

    def self.commands_in_object_space
      commands = Hash.new
      ::ObjectSpace.each_object(Class) do |klass|
        if(RailsRefactor::Commands::Base > klass)
          commands[klass.name.gsub(/.*\:\:/, '').underscore.to_sym] = klass
        end
      end
      commands
    end

    def require_commands
      Find.find(File.join(File.dirname(__FILE__), 'commands')) do |path|
        if File.file?(path) && path.match(/\.rb$/)
          require path
        end
      end
    end

    def execute(options)
      command = @command_klass.new(options)
      command.run(@command_args)
      reset
    end

    def reset
      @command_klass = nil
      @command_args = Array.new
    end

  end
end
