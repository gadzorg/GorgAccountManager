class AddSmsCheckCountToRecoverysessions < ActiveRecord::Migration
  def change
    add_column :recoverysessions, :sms_check_count, :integer
  end
end