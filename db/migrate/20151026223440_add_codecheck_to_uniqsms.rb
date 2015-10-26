class AddCodecheckToUniqsms < ActiveRecord::Migration
  def change
    add_column :uniqsms, :check_count, :integer
  end
end
