class AddInscriptionToUniqlink < ActiveRecord::Migration[4.2]
  def change
    add_column :uniqlinks, :inscription, :boolean
  end
end
