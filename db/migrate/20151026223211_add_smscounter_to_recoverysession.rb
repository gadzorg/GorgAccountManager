class AddSmscounterToRecoverysession < ActiveRecord::Migration
  def change
    add_column :recoverysessions, :sms_count, :integer
  end
end
