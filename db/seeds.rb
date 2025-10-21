# Clear existing data (optional - comment out if you want to keep existing data)
puts "Clearing existing data..."
Report.destroy_all
Comment.destroy_all
User.destroy_all
Barangay.destroy_all
Category.destroy_all

puts "Creating Barangays (All 16 Parañaque Barangays)..."
barangays = [
  { name: "Barangay BF Homes", address: "BF Homes, Parañaque City, Metro Manila", contact_number: "02-8820-7301", contact_email: "bfhomes@paranaque.gov.ph" },
  { name: "Barangay Don Bosco", address: "Don Bosco, Parañaque City, Metro Manila", contact_number: "02-8820-7302", contact_email: "donbosco@paranaque.gov.ph" },
  { name: "Barangay Don Galo", address: "Don Galo, Parañaque City, Metro Manila", contact_number: "02-8820-7303", contact_email: "dongalo@paranaque.gov.ph" },
  { name: "Barangay La Huerta", address: "La Huerta, Parañaque City, Metro Manila", contact_number: "02-8820-7304", contact_email: "lahuerta@paranaque.gov.ph" },
  { name: "Barangay Marcelo Green", address: "Marcelo Green, Parañaque City, Metro Manila", contact_number: "02-8820-7305", contact_email: "marcelogreen@paranaque.gov.ph" },
  { name: "Barangay Merville", address: "Merville, Parañaque City, Metro Manila", contact_number: "02-8820-7306", contact_email: "merville@paranaque.gov.ph" },
  { name: "Barangay Moonwalk", address: "Moonwalk, Parañaque City, Metro Manila", contact_number: "02-8820-7307", contact_email: "moonwalk@paranaque.gov.ph" },
  { name: "Barangay San Antonio", address: "San Antonio, Parañaque City, Metro Manila", contact_number: "02-8820-7308", contact_email: "sanantonio@paranaque.gov.ph" },
  { name: "Barangay San Dionisio", address: "San Dionisio, Parañaque City, Metro Manila", contact_number: "02-8820-7309", contact_email: "sandionisio@paranaque.gov.ph" },
  { name: "Barangay San Isidro", address: "San Isidro, Parañaque City, Metro Manila", contact_number: "02-8820-7310", contact_email: "sanisidro@paranaque.gov.ph" },
  { name: "Barangay San Martin de Porres", address: "San Martin de Porres, Parañaque City, Metro Manila", contact_number: "02-8820-7311", contact_email: "sanmartin@paranaque.gov.ph" },
  { name: "Barangay Santo Niño", address: "Santo Niño, Parañaque City, Metro Manila", contact_number: "02-8820-7312", contact_email: "santonino@paranaque.gov.ph" },
  { name: "Barangay Sun Valley", address: "Sun Valley, Parañaque City, Metro Manila", contact_number: "02-8820-7313", contact_email: "sunvalley@paranaque.gov.ph" },
  { name: "Barangay Tambo", address: "Tambo, Parañaque City, Metro Manila", contact_number: "02-8820-7314", contact_email: "tambo@paranaque.gov.ph" },
  { name: "Barangay Vitalez", address: "Vitalez, Parañaque City, Metro Manila", contact_number: "02-8820-7315", contact_email: "vitalez@paranaque.gov.ph" },
  { name: "Barangay Baclaran", address: "Baclaran, Parañaque City, Metro Manila", contact_number: "02-8820-7316", contact_email: "baclaran@paranaque.gov.ph" }
]

barangays_created = barangays.map do |barangay_data|
  Barangay.create!(barangay_data)
end
puts "Created #{barangays_created.count} barangays"

puts "\nCreating Categories..."
categories = [
  { name: "Flooding", description: "Water accumulation and flood-related issues", icon: "💧" },
  { name: "Road Damage", description: "Potholes, cracks, and road infrastructure problems", icon: "🛣️" },
  { name: "Streetlight", description: "Broken or non-functioning street lights", icon: "💡" },
  { name: "Stoplight", description: "Traffic light malfunctions", icon: "🚦" },
  { name: "Sidewalks", description: "Damaged or obstructed sidewalks", icon: "🚶" },
  { name: "Drainage", description: "Clogged or damaged drainage systems", icon: "🚰" },
  { name: "Garbage", description: "Waste management and disposal issues", icon: "🗑️" }
]

categories_created = categories.map do |category_data|
  Category.create!(category_data)
end
puts "Created #{categories_created.count} categories"

puts "\nCreating Test Users..."

# Admin User
admin = User.create!(
  email: "admin@test.com",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  confirmed_at: Time.current
)
puts "✅ Created Admin: admin@test.com / password123"

# Barangay Official User (assigned to first barangay)
official = User.create!(
  email: "official@test.com",
  password: "password123",
  password_confirmation: "password123",
  role: :barangay_official,
  barangay: barangays_created.first,
  confirmed_at: Time.current
)
puts "✅ Created Barangay Official: official@test.com / password123"
puts "   Assigned to: #{barangays_created.first.name}"

# Resident User
resident = User.create!(
  email: "resident@test.com",
  password: "password123",
  password_confirmation: "password123",
  role: :resident,
  confirmed_at: Time.current
)
puts "✅ Created Resident: resident@test.com / password123"

puts "\n" + "="*60
puts "🎉 Seed data created successfully!"
puts "="*60
puts "\n📧 Test Accounts:"
puts "   Admin:              admin@test.com / password123"
puts "   Barangay Official:  official@test.com / password123 (Assigned to: #{barangays_created.first.name})"
puts "   Resident:           resident@test.com / password123"
puts "\n📊 Data Created:"
puts "   Barangays:  #{Barangay.count}"
puts "   Categories: #{Category.count}"
puts "   Users:      #{User.count}"
puts "\n💡 Next Steps:"
puts "   1. Login with any test account above"
puts "   2. Test creating reports as resident"
puts "   3. Login as admin to create more captain accounts"
puts "   4. Remaining #{16 - 1} barangays need captains (use admin UI)"
puts "\n🎯 To Create More Captains:"
puts "   • Login as admin@test.com"
puts "   • Go to Dashboard → 'Create Captain Account'"
puts "   • Select barangay and enter email"
puts "   • System auto-generates password"
puts "="*60
