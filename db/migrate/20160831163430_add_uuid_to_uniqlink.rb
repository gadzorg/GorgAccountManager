class AddUuidToUniqlink < ActiveRecord::Migration
  def change
    add_column :uniqlinks, :uuid, :string
  end
end
