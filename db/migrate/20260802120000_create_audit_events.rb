class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.references :actor, null: true, foreign_key: { to_table: :users }
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_address
      t.string :user_agent
      t.timestamps

      t.index [ :target_type, :target_id ]
      t.index :action
      t.index :created_at
    end
  end
end
