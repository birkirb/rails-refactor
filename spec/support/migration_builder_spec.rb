require 'spec/spec_helper'

empty_migration = <<-EMPTY_MIGRATION
class CoolMigration < ActiveRecord::Migration
  def self.up

  end

  def self.down

  end
end
EMPTY_MIGRATION

describe RailsRefactor::Support::MigrationBuilder do

  it 'should initialize with a migration_name' do
    RailsRefactor::Support::MigrationBuilder.new('CoolMigration')
  end

  it 'should generate an migration file name base on the given migration name' do
    mb = RailsRefactor::Support::MigrationBuilder.new('CoolMigration')
    mb.file_name.should == "#{RAILS_ROOT}/db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_cool_migration.rb"
  end

  it '#to_s should return the migration built' do
    mb = RailsRefactor::Support::MigrationBuilder.new('CoolMigration')
    mb.to_s.should == empty_migration
  end

  it 'should generate rename table migrations when so called' do
    mb = RailsRefactor::Support::MigrationBuilder.new('CoolMigration')
    mb.rename_table('parasites', 'users')
    mb.to_s.should match(/def self.up\n\s+rename_table\(:parasites, :users\)/)
    mb.to_s.should match(/def self.down\n\s+rename_table\(:users, :parasites\)/)
  end

  it 'should save the migration to the rails db/migrate directory' do
    expected_file_Name = "#{RAILS_ROOT}/db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_rename_parasites_to_users.rb"
    mb = RailsRefactor::Support::MigrationBuilder.new('RenameParasitesToUsers')
    File.exists?(expected_file_Name).should be_false
    mb.save
    File.exists?(expected_file_Name).should be_true
  end

  after(:all) do
    save_files = "#{RAILS_ROOT}/db/migrate/*_rename_parasites_to_users.rb"
    FileUtils.rm Dir.glob(save_files)
  end

end
