class CreateBarangays < ActiveRecord::Migration[8.0]
  def change
    create_table :barangays do |t|
      t.string :name
      t.text :description
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.string :contact_number
      t.string :contact_email

      t.timestamps
    end
  end
end
