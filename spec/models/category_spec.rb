require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      category = build(:category)
      expect(category).to be_valid
    end

    it "requires a name" do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name" do
      create(:category, name: "Flooding")
      category = build(:category, name: "Flooding")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("has already been taken")
    end

    it "is case insensitive for uniqueness" do
      create(:category, name: "Flooding")
      category = build(:category, name: "flooding")
      expect(category).not_to be_valid
    end
  end

  describe "associations" do
    it "will have many reports" do
      # We'll test this when Report model is created
      expect(Category.new).to respond_to(:reports)
    end
  end

  describe "scopes or methods" do
    it "orders by name alphabetically by default" do
      category_c = create(:category, name: "Zebra")
      category_a = create(:category, name: "Apple")
      category_b = create(:category, name: "Mango")

      expect(Category.all.pluck(:name)).to eq([ "Apple", "Mango", "Zebra" ])
    end

    it "normalizes name to title case" do
      category = create(:category, name: "road damage")
      expect(category.name).to eq("Road Damage")
    end
  end
end
