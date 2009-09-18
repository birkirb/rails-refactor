require 'spec/spec_helper'

describe RailsRefactor::Commands::Rename do

  before(:all) do
    FileUtils.cd(RAILS_ROOT)
  end

  it 'can be initialize with no parameters' do
    RailsRefactor::Commands::Rename.new
  end

  it 'should not run without two arguments' do
    rename = RailsRefactor::Commands::Rename.new
    lambda { rename.run('stuff') }.should raise_error(RuntimeError, 'incorrect arguments for rename: stuff')
  end

  it 'should accept a `to` and `from` argument' do
    rename = RailsRefactor::Commands::Rename.new
    do_with_stdout do
      lambda { rename.run('non matching string', 'other non matching string') }.should_not raise_error
    end
  end

  it 'should accept an array with a `to` and `from` argument' do
    rename = RailsRefactor::Commands::Rename.new
    args = ['non matching string', 'other non matching string']
    do_with_stdout do
      lambda { rename.run(args) }.should_not raise_error
    end
  end

  after(:all) do
    FileUtils.cd(RAILS_REFACTOR_ROOT)
  end
end
