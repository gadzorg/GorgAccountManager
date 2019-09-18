class AddUuidToUniqsms < ActiveRecord::Migration[4.2]
  def change
    add_column :uniqsms, :uuid, :string
  end
end
