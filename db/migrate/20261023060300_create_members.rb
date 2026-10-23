class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.string :name
      t.string :phone, null: false, index: { unique: true }
      t.string :neighborhood
      t.string :source, null: false, default: "whatsapp_group"
      t.references :invited_by, foreign_key: { to_table: :members }
      t.boolean :admin, null: false, default: false
      t.datetime :joined_at
      t.string :sign_in_code_digest
      t.datetime :sign_in_code_sent_at
      t.integer :sign_in_code_attempts, null: false, default: 0
      t.timestamps
    end
  end
end
