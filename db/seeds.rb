# Clear existing data
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
  Barangay.find_or_create_by!(name: barangay_data[:name]) do |barangay|
    barangay.assign_attributes(barangay_data)
  end
end
puts "Created #{barangays_created.count} barangays"

puts "\nCreating Categories..."
categories = [
  { name: "Flooding", description: "Water accumulation and flood-related issues" },
  { name: "Road Damage", description: "Potholes, cracks, and road infrastructure problems" },
  { name: "Streetlight", description: "Broken or non-functioning street lights" },
  { name: "Stoplight", description: "Traffic light malfunctions" },
  { name: "Sidewalks", description: "Damaged or obstructed sidewalks" },
  { name: "Drainage", description: "Clogged or damaged drainage systems" },
  { name: "Garbage", description: "Waste management and disposal issues" },
  { name: "Others", description: "Other issues not covered by the above categories" }
]

categories_created = categories.map do |category_data|
  Category.find_or_create_by!(name: category_data[:name]) do |category|
    category.assign_attributes(category_data)
  end
end
puts "Created #{categories_created.count} categories"

puts "\nCreating Test Users..."

# Admin User
admin = User.find_or_create_by!(email: "alea.mikaela04@gmail.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
  user.confirmed_at = Time.current
end
puts "✅ Created Admin: alea.mikaela04@gmail.com / password123"

# Barangay Captain 1 - BF Homes
bf_homes = barangays_created.find { |b| b.name == "Barangay BF Homes" }
captain1 = User.find_or_create_by!(email: "amlopez14+bfhomes@up.edu.ph") do |user|
  user.password = "Captain2024!"
  user.password_confirmation = "Captain2024!"
  user.role = :barangay_official
  user.barangay = bf_homes
  user.confirmed_at = Time.current
end
puts "✅ Created Barangay Captain: amlopez14+bfhomes@up.edu.ph / Captain2024!"
puts "   Assigned to: #{bf_homes.name}"

# Barangay Captain 2 - San Isidro
san_isidro = barangays_created.find { |b| b.name == "Barangay San Isidro" }
captain2 = User.find_or_create_by!(email: "amlopez14+sanisidro@up.edu.ph") do |user|
  user.password = "Captain2024!"
  user.password_confirmation = "Captain2024!"
  user.role = :barangay_official
  user.barangay = san_isidro
  user.confirmed_at = Time.current
end
puts "✅ Created Barangay Captain: amlopez14+sanisidro@up.edu.ph / Captain2024!"
puts "   Assigned to: #{san_isidro.name}"

# Barangay Captain 3 - San Dionisio
san_dionisio = barangays_created.find { |b| b.name == "Barangay San Dionisio" }
captain3 = User.find_or_create_by!(email: "amlopez14+sandionisio@up.edu.ph") do |user|
  user.password = "Captain2024!"
  user.password_confirmation = "Captain2024!"
  user.role = :barangay_official
  user.barangay = san_dionisio
  user.confirmed_at = Time.current
end
puts "✅ Created Barangay Captain: amlopez14+sandionisio@up.edu.ph / Captain2024!"
puts "   Assigned to: #{san_dionisio.name}"

# Resident User
resident = User.find_or_create_by!(email: "ammlopez04@gmail.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :resident
  user.barangay = san_isidro
  user.confirmed_at = Time.current
end
puts "✅ Created Resident: ammlopez04@gmail.com / password123"
puts "   Assigned to: #{resident.barangay.name}"

puts "\nCreating Test Reports (at least 2 per barangay)..."
# Create test reports for each barangay
barangays_created.each do |barangay|
  report_titles = [
    "Pothole on Main Street",
    "Broken Streetlight",
    "Clogged Drainage System",
    "Damaged Sidewalk",
    "Garbage Collection Issue",
    "Fallen Tree Branch",
    "Traffic Light Malfunction",
    "Flooding in Residential Area"
  ]
  
  # Create 2-4 reports per barangay
  rand(2..4).times do
    category = categories_created.sample
    report = Report.create!(
      title: report_titles.sample,
      description: "Issue reported in #{barangay.name}. Needs attention from local authorities.",
      address: barangay.address,
      status: [:pending, :in_progress, :resolved, :closed].sample,
      priority: [:low, :medium, :high].sample,
      barangay: barangay,
      category: category,
      user: resident,
      latitude: barangay.latitude,
      longitude: barangay.longitude
    )
    puts "  Created report: #{report.title} in #{barangay.name}"
  end
end
puts "Created #{Report.count} reports"

puts "\n" + "="*60
puts "🎉 Seed data created successfully!"
puts "="*60
puts "\n📧 Test Accounts:"
puts "   Admin:              alea.mikaela04@gmail.com / password123"
puts "\n   Barangay Captains:"
puts "   • amlopez14+bfhomes@up.edu.ph / Captain2024! (BF Homes)"
puts "   • amlopez14+sanisidro@up.edu.ph / Captain2024! (San Isidro)"
puts "   • amlopez14+sandionisio@up.edu.ph / Captain2024! (San Dionisio)"
puts "\n   Resident:          ammlopez04@gmail.com / password123"
puts "   New Sign Up:       mikaela080499@gmail.com (sign up with barangay)"
puts "\n📊 Data Created:"
puts "   Barangays:  #{Barangay.count}"
puts "   Categories: #{Category.count}"
puts "   Users:      #{User.count}"
puts "   Captains:   #{User.barangay_official.count}"
puts "   Reports:    #{Report.count}"
puts "\n💡 Next Steps:"
puts "   1. Login with any test account above"
puts "   2. Test creating reports as resident"
puts "   3. Login as admin to create more captain accounts"
puts "   4. Remaining #{16 - 3} barangays need captains (use admin UI)"
puts "\n🎯 To Create More Captains:"
puts "   • Login as alea.mikaela04@gmail.com"
puts "   • Go to Dashboard → 'Create Captain Account'"
puts "   • Select barangay and enter email"
puts "   • System auto-generates password"
puts "\n📧 Email Testing:"
puts "   • Create reports as resident → Emails sent to barangay captains"
puts "   • Reopen requests → Admin receives notification"
puts "   • Check Resend dashboard for email delivery"
puts "="*60
