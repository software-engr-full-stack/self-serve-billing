class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :name, null: false
      t.string :password_digest, null: false
      t.text :notes, :jsonb, default: "{}"

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :name
  end
end
