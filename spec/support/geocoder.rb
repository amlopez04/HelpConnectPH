# Stub Geocoder for tests to avoid external API calls
RSpec.configure do |config|
  config.before(:each) do
    Geocoder.configure(lookup: :test)
    Geocoder::Lookup::Test.reset

    # Default stub for Parañaque coordinates
    Geocoder::Lookup::Test.set_default_stub([
      {
        'latitude' => 14.4793095,
        'longitude' => 121.0198229,
        'address' => 'Parañaque, PH',
        'city' => 'Parañaque',
        'state' => 'Metro Manila',
        'country' => 'Philippines'
      }
    ])
  end
end
