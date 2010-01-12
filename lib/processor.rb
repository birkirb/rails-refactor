require 'commands/rename'
require 'commands/find'
require 'scm/abstract'
require 'scm/file'
require 'scm/git'
require 'scm/svn'

module RailsRefactor
  class Processor

    # TODO: Load this dynamically
    COMMANDS = {
      :rename => RailsRefactor::Commands::Rename,
      :find => RailsRefactor::Commands::Find
    }

    def initialize(options)
      @options = options
      @options[:scm] = set_scm(options[:scm])
      reset
    end

    def file_commands(file)
      File.readlines(file).each do |line|
        command_line(line.split(' '))
      end
    end

    def command_line(args)
      args.each do |arg|
        if klass = COMMANDS[arg.to_sym]
          execute if @command_klass
          @command_klass = klass
        else
          @command_args << arg
        end
      end
      execute
    end

    private

    def execute
      command = @command_klass.new(@options)
      command.run(@command_args)
      reset
    end

    def reset
      @command_klass = nil
      @command_args = Array.new
    end

    def set_scm(scm)
      if scm
        case
        when File.directory?(".git")
          SCM::Git.new
        when File.directory?(".svn")
          SCM::SVN.new
        else
          SCM::File.new
        end
      else
        SCM::File.new
      end
    end

  end
end
