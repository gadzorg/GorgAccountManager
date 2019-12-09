class AddSmsCheckCountToRecoverysessions < ActiveRecord::Migration[4.2]
  def change
    add_column :recoverysessions, :sms_check_count, :integer
  end
end