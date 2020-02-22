class Users < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :fname, null: false
      t.string :lname, null: false
      t.timestamps
    end
  end
end
