class AddUuidToRecoverySession < ActiveRecord::Migration[4.2]
  def change
    add_column :recoverysessions, :uuid, :string
  end
end
