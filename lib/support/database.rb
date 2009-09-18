require 'active_record'

module RailsRefactor
  module Support
    class Database
      require File.join(RAILS_ROOT, 'config', 'environment')

      def initialize()
        ActiveRecord::Base.establish_connection
      end

      def table_exists?(table_name)
        ActiveRecord::Base.connection.table_exists?(table_name)
      end

      def table_columns(table_name)
        if table_exists?(table_name)
          ActiveRecord::Base.connection.columns(table_name).map { |column| column.name }
        else
          []
        end
      end

    end
  end
end
