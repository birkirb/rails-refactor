require 'spec/spec_helper'

describe RailsRefactor::Support::Database do
  it 'should initialize with no parameters' do
    RailsRefactor::Support::Database.new
  end

  it 'should recognize table existance' do
    database = RailsRefactor::Support::Database.new
    database.table_exists?('test').should == false
    database.table_exists?('parasites').should == true
  end

  it 'should give an array of table column names' do
    database = RailsRefactor::Support::Database.new
    database.table_columns(:test).should == []
    database.table_columns(:parasites).should == ['id', 'name', 'created_at', 'updated_at']
  end

  it 'should give an array of table names in the database' do
    database = RailsRefactor::Support::Database.new
    database.tables.should == ['schema_migrations', 'parasites']
  end
end
