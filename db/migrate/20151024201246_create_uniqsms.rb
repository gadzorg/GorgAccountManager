class CreateUniqsms < ActiveRecord::Migration[4.2]
  def change
    create_table :uniqsms do |t|
      t.string :hruid
      t.string :token
      t.boolean :used
      t.datetime :expire_date

      t.timestamps null: false
    end
  end
end
