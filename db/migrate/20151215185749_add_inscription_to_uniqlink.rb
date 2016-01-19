class AddInscriptionToUniqlink < ActiveRecord::Migration
  def change
    add_column :uniqlinks, :inscription, :boolean
  end
end
