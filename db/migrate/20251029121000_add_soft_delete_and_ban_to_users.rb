class AddSoftDeleteAndBanToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :banned_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :users, :ban_reason, :string

    add_index :users, :banned_at
    add_index :users, :deleted_at
  end
end
