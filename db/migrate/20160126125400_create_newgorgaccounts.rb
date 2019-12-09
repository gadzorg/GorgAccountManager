class CreateNewgorgaccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :newgorgaccounts do |t|
      t.string :hruid
      t.string :email
      t.boolean :wantsgoogleapps
      t.string :promo
      t.string :tbk

      t.timestamps null: false
    end
  end
end
