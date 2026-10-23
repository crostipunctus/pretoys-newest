class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :member, null: false, foreign_key: true
      t.string :token, null: false, index: { unique: true }
      t.string :title, null: false
      t.text :description
      t.integer :price, null: false, default: 0
      t.string :category, null: false
      t.string :age_group
      t.string :condition, null: false, default: "good"
      t.string :status, null: false, default: "available"
      t.string :neighborhood
      t.timestamps
    end
    add_index :listings, [ :status, :created_at ]
  end
end
