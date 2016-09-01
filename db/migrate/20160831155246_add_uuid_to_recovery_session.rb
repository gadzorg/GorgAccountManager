class AddUuidToRecoverySession < ActiveRecord::Migration
  def change
    add_column :recoverysessions, :uuid, :string
  end
end
