require 'rubygems'
require 'spec'

::RAILS_ROOT = File.join(File.dirname(__FILE__), 'test_app')

require 'lib/support/database'
require 'lib/support/migration_builder'
