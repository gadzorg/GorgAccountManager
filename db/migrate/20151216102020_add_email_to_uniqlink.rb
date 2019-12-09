class AddEmailToUniqlink < ActiveRecord::Migration[4.2]
  def change
    add_column :uniqlinks, :email, :string
  end
end
