class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :action_url
      t.datetime :read_at
      t.jsonb :metadata, null: false, default: {}
      t.string :dedupe_key

      t.timestamps
    end

    add_index :notifications, [ :user_id, :created_at ]
    add_index :notifications, [ :user_id, :read_at ]
    add_index :notifications, [ :user_id, :dedupe_key ], unique: true, where: "dedupe_key IS NOT NULL"
  end
end
