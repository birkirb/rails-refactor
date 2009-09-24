class CreateParasiteInfos < ActiveRecord::Migration
  def self.up
    create_table :parasite_infos do |t|
      t.integer :parasite_id
      t.string :dwellings
      t.timestamps
    end
  end

  def self.down
    drop_table :parasite_infos
  end
end
