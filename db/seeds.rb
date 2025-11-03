# Skip seeding in test environment
unless Rails.env.test?
  # Avoid hitting external geocoding service during seeds to prevent JSON errors/rate limits
  begin
    Geocoder.configure(lookup: :test)
    Geocoder::Lookup::Test.set_default_stub([
      {
        'latitude' => 14.4793095,
        'longitude' => 121.0198229,
        'address' => 'Parañaque, PH'
      }
    ])
  rescue NameError
    # Geocoder not loaded in this context; ignore
  end
  # Helper: Parañaque safe center coordinates and bounds check
  CENTER_LAT = 14.4793095
  CENTER_LNG = 121.0198229
  NORTH = 14.5050
  SOUTH = 14.4580
  EAST  = 121.0450
  WEST  = 120.9730

  def within_paranaque_bounds?(lat, lng)
    lat && lng && lat > SOUTH && lat < NORTH && lng > WEST && lng < EAST
  end

  def safe_coords_for(barangay)
    lat = barangay.latitude&.to_f
    lng = barangay.longitude&.to_f
    return [CENTER_LAT, CENTER_LNG] unless within_paranaque_bounds?(lat, lng)
    [lat, lng]
  end

  # Clear existing data
  puts "Clearing existing data..."
  Report.destroy_all
  Comment.destroy_all
  User.destroy_all
  Barangay.destroy_all
  Category.destroy_all

  puts "Creating Barangays (All 16 Parañaque Barangays)..."
  barangays = [
    { name: "Barangay BF Homes", address: "BF Homes, Parañaque City, Metro Manila", contact_number: "02-8820-7301", contact_email: "amlopez14+bfhomes@up.edu.ph" },
    { name: "Barangay Don Bosco", address: "Don Bosco, Parañaque City, Metro Manila", contact_number: "02-8820-7302", contact_email: "amlopez14+donbosco@up.edu.ph" },
    { name: "Barangay Don Galo", address: "Don Galo, Parañaque City, Metro Manila", contact_number: "02-8820-7303", contact_email: "amlopez14+dongalo@up.edu.ph" },
    { name: "Barangay La Huerta", address: "La Huerta, Parañaque City, Metro Manila", contact_number: "02-8820-7304", contact_email: "amlopez14+lahuerta@up.edu.ph" },
    { name: "Barangay Marcelo Green", address: "Marcelo Green, Parañaque City, Metro Manila", contact_number: "02-8820-7305", contact_email: "amlopez14+marcelogreen@up.edu.ph" },
    { name: "Barangay Merville", address: "Merville, Parañaque City, Metro Manila", contact_number: "02-8820-7306", contact_email: "amlopez14+merville@up.edu.ph" },
    { name: "Barangay Moonwalk", address: "Moonwalk, Parañaque City, Metro Manila", contact_number: "02-8820-7307", contact_email: "amlopez14+moonwalk@up.edu.ph" },
    { name: "Barangay San Antonio", address: "San Antonio, Parañaque City, Metro Manila", contact_number: "02-8820-7308", contact_email: "amlopez14+sanantonio@up.edu.ph" },
    { name: "Barangay San Dionisio", address: "San Dionisio, Parañaque City, Metro Manila", contact_number: "02-8820-7309", contact_email: "amlopez14+sandionisio@up.edu.ph" },
    { name: "Barangay San Isidro", address: "San Isidro, Parañaque City, Metro Manila", contact_number: "02-8820-7310", contact_email: "amlopez14+sanisidro@up.edu.ph" },
    { name: "Barangay San Martin de Porres", address: "San Martin de Porres, Parañaque City, Metro Manila", contact_number: "02-8820-7311", contact_email: "amlopez14+sanmartindeporres@up.edu.ph" },
    { name: "Barangay Santo Niño", address: "Santo Niño, Parañaque City, Metro Manila", contact_number: "02-8820-7312", contact_email: "amlopez14+santonino@up.edu.ph" },
    { name: "Barangay Sun Valley", address: "Sun Valley, Parañaque City, Metro Manila", contact_number: "02-8820-7313", contact_email: "amlopez14+sunvalley@up.edu.ph" },
    { name: "Barangay Tambo", address: "Tambo, Parañaque City, Metro Manila", contact_number: "02-8820-7314", contact_email: "amlopez14+tambo@up.edu.ph" },
    { name: "Barangay Vitalez", address: "Vitalez, Parañaque City, Metro Manila", contact_number: "02-8820-7315", contact_email: "amlopez14+vitalez@up.edu.ph" },
    { name: "Barangay Baclaran", address: "Baclaran, Parañaque City, Metro Manila", contact_number: "02-8820-7316", contact_email: "amlopez14+baclaran@up.edu.ph" }
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

  # Create 16 Residents - one for each barangay (ammlopez04@gmail.com through ammlopez04+15@gmail.com)
  puts "\nCreating Residents (one per barangay)..."
  residents_created = []
  barangays_created.each_with_index do |barangay, index|
    email = index.zero? ? "ammlopez04@gmail.com" : "ammlopez04+#{index}@gmail.com"
    resident = User.find_or_create_by!(email: email) do |user|
      user.password = "password123"
      user.password_confirmation = "password123"
      user.role = :resident
      user.barangay = barangay
      user.confirmed_at = Time.current
    end
    residents_created << resident
    puts "  ✅ Resident: #{email} (assigned to #{barangay.name})"
  end

  # Create 15 Officials - one for each barangay except the last one
  puts "\nCreating Barangay Officials (one for each barangay except the last)..."
  officials_created = []
  barangays_created.first(15).each_with_index do |barangay, index|
    # Simplify barangay name for email
    barangay_key = barangay.name.gsub("Barangay ", "").downcase.gsub(" ", "").gsub("deporres", "de-porres")
    email = "amlopez14+#{barangay_key}@up.edu.ph"

    official = User.find_or_create_by!(email: email) do |user|
      user.password = "Captain2024!"
      user.password_confirmation = "Captain2024!"
      user.role = :barangay_official
      user.barangay = barangay
      user.confirmed_at = Time.current
    end
    officials_created << official

    # Update barangay contact_email to match official's email
    barangay.update(contact_email: email)

    puts "  ✅ Official: #{email} (assigned to #{barangay.name})"
  end

  puts "\nCreating Sample Spam Users (for ban testing)..."
  spam_users = []
  3.times do |i|
    spam_user = User.find_or_create_by!(email: "spammer#{i + 1}@test.com") do |user|
      user.password = "password123"
      user.password_confirmation = "password123"
      user.role = :resident
      user.barangay = barangays_created.sample
      user.confirmed_at = Time.current
      user.phone_number = "+63912345678#{i}"
    end
    
    # Create spam reports (many reports in short time) including gibberish text
    if spam_user.persisted?
      gibberish_samples = [
        "fahwefhuawfhuawefhuawfhuawfhawfhuawfhuawef",
        "qwrtypklzxcvbnmghjdfghjdfghjdfghjdfg",
        "zzzzzzzzzzzzzzzzzzzzzzzz",
        "bvvccxnnmmqwrtplkjhgfdsa"
      ]

      3.times do |j|
        lat, lng = safe_coords_for(spam_user.barangay)
        Report.create!(
          title: "Gibberish Report #{j + 1}",
          description: gibberish_samples.sample,
          address: spam_user.barangay.address,
          status: :pending_approval,
          priority: :medium,
          barangay: spam_user.barangay,
          category: categories_created.sample,
          user: spam_user,
          latitude: lat,
          longitude: lng,
          created_at: j.hours.ago
        )
      end

      3.times do |j|
        lat, lng = safe_coords_for(spam_user.barangay)
        Report.create!(
          title: "Spam Burst #{j + 1}",
          description: "Buy now! Visit http://spam.example/",
          address: spam_user.barangay.address,
          status: :pending_approval,
          priority: :medium,
          barangay: spam_user.barangay,
          category: categories_created.sample,
          user: spam_user,
          latitude: lat,
          longitude: lng,
          created_at: (j + 3).hours.ago
        )
      end
      spam_users << spam_user
      puts "  ✅ Spam User: #{spam_user.email} (created #{spam_user.reports.count} spam reports)"
    end
  end

  puts "\nCreating Test Reports (at least 2 per barangay by residents from that barangay)..."
  # Create test reports for each barangay using the resident from that barangay
  barangays_created.each do |barangay|
    resident = residents_created.find { |r| r.barangay == barangay }
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

    # Create 2-4 reports per barangay (no more :closed status)
    rand(2..4).times do
      category = categories_created.sample
      lat, lng = safe_coords_for(barangay)
      report = Report.create!(
        title: report_titles.sample,
        description: "Issue reported in #{barangay.name}. Needs attention from local authorities.",
        address: barangay.address,
        status: [ :pending, :in_progress, :resolved ].sample,
        priority: :medium,
        barangay: barangay,
        category: category,
        user: resident,
        latitude: lat,
        longitude: lng
      )
      puts "  Created report: #{report.title} in #{barangay.name} by #{resident.email}"
    end
  end
  puts "Created #{Report.count} reports"

  # Sample Reopen Requested reports
  puts "\nCreating sample 'Reopen Requested' reports..."
  [0, 1].each do |idx|
    resident = residents_created[idx]
    next unless resident
    barangay = resident.barangay
    lat, lng = safe_coords_for(barangay)
    Report.create!(
      title: "Request to Reopen ##{idx + 1}",
      description: "Resident requests to reopen this issue for further attention.",
      address: barangay.address,
      status: :reopen_requested,
      priority: :medium,
      barangay: barangay,
      category: categories_created.sample,
      user: resident,
      latitude: lat,
      longitude: lng
    )
  end

  puts "\n" + "="*60
  puts "🎉 Seed data created successfully!"
  puts "="*60
  puts "\n📧 Test Accounts:"
  puts "   Admin:              alea.mikaela04@gmail.com / password123"
  puts "\n   Barangay Officials (15 total):"
  officials_created.each do |official|
    puts "   • #{official.email} / Captain2024! (#{official.barangay.name})"
  end
  puts "\n   Residents (16 total, one per barangay):"
  residents_created.each do |resident|
    puts "   • #{resident.email} / password123 (#{resident.barangay.name})"
  end
  puts "\n   🚨 Spam Users (for ban testing - 3 total):"
  spam_users.each do |spam|
    puts "   • #{spam.email} / password123 (#{spam.reports.count} spam reports)"
  end
  puts "\n📊 Data Created:"
  puts "   Barangays:     #{Barangay.count}"
  puts "   Categories:    #{Category.count}"
  puts "   Users:         #{User.count}"
  puts "   Officials:     #{User.barangay_official.count} (15 - one barangay left without official)"
  puts "   Residents:     #{User.resident.count}"
  puts "   Reports:       #{Report.count}"
  puts "\n💡 Note: Last barangay (Baclaran) has NO official - use admin UI to create one"
  puts "="*60
end
