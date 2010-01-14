module RailsRefactor
  module Commands
    class Base

      def run(*args)
        raise "not implemented"
      end

      def self.help(options)
        raise "not implemented"
      end

      def self.help_options(options)
        # no options
      end

    end
  end
end
