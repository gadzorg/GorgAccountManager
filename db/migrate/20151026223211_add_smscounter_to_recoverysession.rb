class AddSmscounterToRecoverysession < ActiveRecord::Migration[4.2]
  def change
    add_column :recoverysessions, :sms_count, :integer
  end
end
