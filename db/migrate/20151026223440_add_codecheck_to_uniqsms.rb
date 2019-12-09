class AddCodecheckToUniqsms < ActiveRecord::Migration[4.2]
  def change
    add_column :uniqsms, :check_count, :integer
  end
end
