require 'rails_helper'

RSpec.describe Barangay, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      barangay = build(:barangay)
      expect(barangay).to be_valid
    end

    it "requires a name" do
      barangay = build(:barangay, name: nil)
      expect(barangay).not_to be_valid
      expect(barangay.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name" do
      create(:barangay, name: "Barangay San Jose")
      barangay = build(:barangay, name: "Barangay San Jose")
      expect(barangay).not_to be_valid
      expect(barangay.errors[:name]).to include("has already been taken")
    end

    it "requires an address" do
      barangay = build(:barangay, address: nil)
      expect(barangay).not_to be_valid
      expect(barangay.errors[:address]).to include("can't be blank")
    end
  end

  describe "geocoding" do
    it "has latitude" do
      barangay = create(:barangay)
      expect(barangay.latitude).not_to be_nil
    end

    it "has longitude" do
      barangay = create(:barangay)
      expect(barangay.longitude).not_to be_nil
    end
  end

  describe "associations" do
    # Skip this test until Report model is created
    # it "will have many reports" do
    #   expect(Barangay.new).to respond_to(:reports)
    # end
  end
end

