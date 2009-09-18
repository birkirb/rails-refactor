require 'active_support'

module RailsRefactor
  module Support
    class MigrationBuilder

      attr_accessor :file_name

      def initialize(migration_name)
        @rails_root = RAILS_ROOT
        @up_commands = Array.new
        @down_commands = Array.new
        @file_name = File.join(@rails_root, 'db', 'migrate', "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{migration_name.underscore}.rb")
        @migration_name = migration_name
      end

      def rename_table(from, to)
        old_table_name = table_name(from)
        new_table_name = table_name(to)
        @up_commands << "    rename_table(:#{old_table_name}, :#{new_table_name})"
        @down_commands << "    rename_table(:#{new_table_name}, :#{old_table_name})"
      end

      def save
        open(@file_name, "w") do |out|
          out.print migration_contents
        end
      end

      def to_s
        migration_contents
      end

      private

      def migration_contents
        <<-MIGRATION
class #{@migration_name} < ActiveRecord::Migration
  def self.up
#{@up_commands.join('\n')}
  end

  def self.down
#{@down_commands.join('\n')}
  end
end
        MIGRATION
      end

      def table_name(value)
        value.gsub(/.*::/, '').pluralize
      end

    end
  end
end
