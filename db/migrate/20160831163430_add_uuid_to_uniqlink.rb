class AddUuidToUniqlink < ActiveRecord::Migration[4.2]
  def change
    add_column :uniqlinks, :uuid, :string
  end
end
