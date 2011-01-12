module RailsRefactor
  module Commands
    class Base

      def run(*args)
        raise "not implemented"
      end

      def self.help
        raise "not implemented"
      end

      def self.help_options(option_parser, options)
        # no changes to option parser
      end

      def self.help_option_defaults(options)
        # no changes to default options
      end

    end
  end
end
