class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.integer :priority
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.references :user, null: false, foreign_key: true
      t.references :barangay, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
