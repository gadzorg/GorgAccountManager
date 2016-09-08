class AddUuidToUniqsms < ActiveRecord::Migration
  def change
    add_column :uniqsms, :uuid, :string
  end
end
