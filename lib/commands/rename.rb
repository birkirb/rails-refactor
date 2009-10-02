require 'find'
require 'rubygems'
require 'active_support'

module RailsRefactor
  module Commands
    class Rename

      IGNORE_DIRECTORIES = ['vendor', 'log', 'tmp', 'db']
      IGNORE_FILE_TYPES =  ['bin', 'git', 'svn', 'sh', 'swp', 'sql', 'rake', 'swf']
      FIND_PRUNE_REGEXP = Regexp.new(/((^\.\/(#{IGNORE_DIRECTORIES.join('|')}))|\.(#{IGNORE_FILE_TYPES.join('|')}))$/)

      def initialize(options = {})
        @scm = options[:scm]
        @execute = (options[:execute] == true)
        @migrate = (options[:migrate] == true)
        load_database_support if @migrate
      end

      def run(*args)
        args.flatten!
        raise "incorrect arguments for rename: #{args}" if args.size != 2

        from, to = args
        @from_singular = from.singularize
        @from_plural = from.pluralize
        @to_singular = to.singularize
        @to_plural = to.pluralize

        rename_files
        rename_files_verbose
        rename_constants_and_variables

        build_migration if @migrate
      end

      private

      def rename_files
        puts "Renaming files and directories:" unless @execute

        rails_renames.each do |from, to|
          if File.exist?(from)
            move_file(from, to)
          end
        end
      end

      def rename_files_verbose
        replaces = {
          @from_singular => @to_singular,
          @from_plural => @to_plural,
        }
        replace_regexp = matching_regexp(replaces.keys)
        rails_renamed = Hash.new
        rails_renames.each { |key, value| rails_renamed[value] = true }

        do_with_found_files do |from_path|
          if match = (from_path =~ replace_regexp) && rails_renamed[from_path].nil?
            to_path = from_path.gsub(replace_regexp) {"#{$1}#{replaces[$2]}#{$3}"}
            responded = false
            while !responded
              if @execute
                print "Do you want move `#{from_path}` => `#{to_path}`? [yes/NO] "
                response = STDIN.readline
                response.chomp!
                if 'yes' == response.downcase
                  move_file(from_path, to_path)
                  responded = true
                elsif 'no' == response.downcase || '' == response
                  responded = true
                else
                  puts "Please answer 'yes' or 'no'.\n"
                end
              else
                puts "move? \"#{from_path}\" \"#{to_path}\""
                responded = true
              end
            end
          end
        end
      end

      def move_file(from, to)
        if @execute
          @scm.move(from,to)
        else
          puts "move \"#{from}\" \"#{to}\""
        end
      end

      def rename_constants_and_variables
        replaces = {
          @from_singular => @to_singular,
          @from_plural => @to_plural,
          @from_singular.classify => @to_singular.classify,
          @from_plural.classify => @to_plural.classify,
        }
        replace_regexp = matching_regexp(replaces.keys)

        if @execute
          do_with_found_files_content do |content, path|
            content.gsub!(replace_regexp) {"#{$1}#{replaces[$2]}#{$3}"}
          end
        else
          puts "Will replacing the following constants and variables:"
          replaces.each do |f,t|
            puts "  #{f} -> #{t}"
          end
          puts "  -- listing matches for this regular expression: #{replace_regexp.to_s}"

          do_with_found_files_content do |content, path|
            content.each_with_index do |line, idx|
              line.strip!
              line.scan(replace_regexp).each do
                puts "  #{path}:#{idx+1}: #{line} "
                puts "    -> #{line.gsub(replace_regexp) {"#{$1}#{replaces[$2]}#{$3}"}}"
              end
            end
            false
          end
          puts
        end
      end

      def load_database_support
        require 'support/migration_builder'
        require 'support/database'
        @db = Support::Database.new
      end

      def build_migration
        if @db.table_exists?(@from_plural)
          migration_name = "Rename#{remove_namespace_seperator(@from_singular.classify.pluralize)}To#{remove_namespace_seperator(@to_plural.classify.pluralize)}"
          @migration_builder = Support::MigrationBuilder.new(migration_name)

          rename_columns
          rename_table

          if @execute
            @migration_builder.save
          else
            puts "Generated the following migration:"
            puts @migration_builder.to_s
            puts ''
          end
        end
      end

      def rename_table
        @migration_builder.rename_table(@from_plural, @to_plural)
      end

      def rename_columns
        replaces = {
          @from_singular => @to_singular,
        }
        replace_regexp = matching_regexp(replaces.keys)

        @db.tables.each do |table|
          @db.table_columns(table).each do |from_column_name|
            to_column_name = from_column_name.dup
            to_column_name.gsub!(replace_regexp) {"#{$1}#{replaces[$2]}#{$3}"}
            if to_column_name != from_column_name
              @migration_builder.rename_column(table, from_column_name, to_column_name)
            end
          end
        end
      end

      def do_with_found_files
        Find.find(".") do |path|
          if path =~ FIND_PRUNE_REGEXP
            Find.prune
          else
            yield(path)
          end
        end
      end

      def do_with_found_files_content
        do_with_found_files do |path|
          if File.file?(path)
            content = File.read(path)
            if replaced = yield(content, path)
              open(path, "w") do |out|
                out.print content
              end
            end
          end
        end
      end

      def matching_regexp(keys)
        Regexp.new("(\\b|_)(#{keys.join("|")})(\\b|[_A-Z])")
      end

      def remove_namespace_seperator(value)
        value.sub('::', '')
      end

      def rails_renames
        {
          "./app/models/#{@from_singular}.rb"                      => "./app/models/#{@to_singular}.rb",
          "./app/models/#{@from_singular}_sweeper.rb"              => "./app/models/#{@to_singular}_sweeper.rb",
          "./test/unit/#{@from_singular}_test.rb"                  => "./test/unit/#{@to_singular}_test.rb",
          "./test/unit/#{@from_singular}_sweeper_test.rb"          => "./test/unit/#{@to_singular}_sweeper_test.rb",
          "./test/fixtures/#{@from_plural}.yml"                    => "./test/fixtures/#{@to_plural}.yml",
          "./app/helpers/#{@from_singular}_helper.rb"              => "./app/helpers/#{@to_singular}_helper.rb",
          "./app/helpers/#{@from_plural}_helper.rb"                => "./app/helpers/#{@to_plural}_helper.rb",
          "./app/controllers/#{@from_singular}_controller.rb"      => "./app/controllers/#{@to_singular}_controller.rb",
          "./app/controllers/#{@from_plural}_controller.rb"        => "./app/controllers/#{@to_plural}_controller.rb",
          "./test/functional/#{@from_singular}_controller_test.rb" => "./test/functional/#{@to_singular}_controller_test.rb",
          "./test/functional/#{@from_plural}_controller_test.rb"   => "./test/functional/#{@to_plural}_controller_test.rb",
          "./app/views/#{@from_singular}"                          => "./app/views/#{@to_singular}",
          "./app/views/#{@from_plural}"                            => "./app/views/#{@to_plural}",
        }
      end

    end
  end
end
