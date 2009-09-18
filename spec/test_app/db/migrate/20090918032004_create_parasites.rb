class CreateParasites < ActiveRecord::Migration
  def self.up
    create_table :parasites do |t|
      t.string(:name)
      t.timestamps
    end
  end

  def self.down
    drop_table :parasites
  end
end
