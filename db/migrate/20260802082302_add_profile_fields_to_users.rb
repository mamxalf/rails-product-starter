class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :preferred_locale, :string, null: false, default: "id"
    add_column :users, :time_zone, :string, null: false, default: "Asia/Jakarta"
    add_column :users, :email_verified_at, :datetime
    add_column :users, :suspended_at, :datetime
    add_column :users, :deactivated_at, :datetime

    add_index :users, :role
    add_index :users, :email_verified_at
    add_index :users, :suspended_at
    add_index :users, :deactivated_at
  end
end
