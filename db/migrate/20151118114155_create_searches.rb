class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :term
      t.string :term_type

      t.timestamps null: false
    end
  end
end
