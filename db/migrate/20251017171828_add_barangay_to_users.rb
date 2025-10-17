class AddBarangayToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :barangay, null: true, foreign_key: true
  end
end
