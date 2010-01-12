require 'find'
require 'rubygems'
require 'active_support'

module RailsRefactor
  module Commands
    class Find

      IGNORE_DIRECTORIES = ['log', 'tmp']
      IGNORE_FILE_TYPES =  ['bin', 'git', 'svn', 'sh', 'swp', 'sql', 'rake', 'swf']
      FIND_PRUNE_REGEXP = Regexp.new(/((^\.\/(#{IGNORE_DIRECTORIES.join('|')}))|\.(#{IGNORE_FILE_TYPES.join('|')}))$/)

      def initialize(options = {})
        set_exclusion_pattern(options[:exclude])
      end

      def run(*args)
        args.flatten!
        raise "missing arguments for command" if args.size < 1

        args.each do |arg|
          @arg_singular = arg.singularize
          @arg_plural = arg.pluralize

          find_in_files
        end
      end

      private

      def find_in_files
        finds = [
          @arg_singular,
          @arg_plural,
          @arg_singular.classify,
          @arg_plural.classify,
        ]
        find_regexp = matching_regexp(finds)

        do_with_found_files_content do |file, path|
          file.each_line do |line|
            if match = line.match(find_regexp)
              puts "#{path}:#{file.lineno}: #{line}"
            end
          end
        end
      end

      def load_database_support
        require 'support/migration_builder'
        require 'support/database'
        @db = Support::Database.new
      end

      def find_in_database
        finds = [
          @arg_singular,
          @arg_plural,
          @arg_singular.classify,
          @arg_plural.classify,
        ]
        find_regexp = matching_regexp(finds)

        @db.tables.each do |table|
          find_in_table(table)
          # TODO: find
        end
      end

      def find_in_table(table)
        @db.table_columns(table).each do |from_column_name|
          # TODO: find
          skipping_exclusion_matches(from_column_name) do
          end
        end
      end

      def do_with_found_files
        ::Find.find(".") do |path|
          if path =~ FIND_PRUNE_REGEXP
            ::Find.prune
          else
            yield(path)
          end
        end
      end

      def do_with_found_files_content
        do_with_found_files do |path|
          if File.file?(path)
            file = File.open(path)
            yield(file, path)
          end
        end
      end

      def matching_regexp(keys)
        Regexp.new("(\\b|_)(#{keys.join("|")})(\\b|[_A-Z])")
      end

      def remove_namespace_seperator(value)
        value.sub('::', '')
      end

      def set_exclusion_pattern(pattern)
        if pattern.blank?
          @exclude = nil
        else
          begin
            @exclude = Regexp.new(pattern)
          rescue => err
            puts err.message
            @exclude = nil
          end
        end
      end

      def skipping_exclusion_matches(string, &block)
        if exclusion_match?(string)
          # do nothing
        else
          yield(string)
        end
      end

      def exclusion_match?(string)
        if @exclude.nil?
          false
        else
          if string =~ @exclude
            true
          else
            false
          end
        end
      end

    end
  end
end
