class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Reports common filters
    add_index :reports, :status unless index_exists?(:reports, :status)
    add_index :reports, :category_id unless index_exists?(:reports, :category_id)
    add_index :reports, :barangay_id unless index_exists?(:reports, :barangay_id)
    add_index :reports, :user_id unless index_exists?(:reports, :user_id)
    add_index :reports, :created_at unless index_exists?(:reports, :created_at)

    # Users lookups
    add_index :users, :phone_number unless index_exists?(:users, :phone_number)
    add_index :users, :created_at unless index_exists?(:users, :created_at)
  end
end
