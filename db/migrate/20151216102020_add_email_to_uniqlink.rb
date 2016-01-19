class AddEmailToUniqlink < ActiveRecord::Migration
  def change
    add_column :uniqlinks, :email, :string
  end
end
