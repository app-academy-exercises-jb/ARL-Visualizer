class Comments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :body, null: false
      t.integer :post_id, null: false
      t.integer :author_id, null: false
      t.timestamps
    end
  end
end
