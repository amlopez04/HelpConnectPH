require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      barangay = create(:barangay)
      user = build(:user, barangay: barangay)
      expect(user).to be_valid
    end

    it "requires an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "requires a unique email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "requires a password" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  describe "roles" do
    it "defines role enum correctly" do
      expect(User.roles.keys).to match_array([ "resident", "barangay_official", "admin" ])
    end

    it "defaults to resident role" do
      barangay = create(:barangay)
      user = create(:user, barangay: barangay)
      expect(user.resident?).to be true
    end

    it "can be a barangay_official" do
      user = create(:user, :barangay_official)
      expect(user.barangay_official?).to be true
      expect(user.resident?).to be false
    end

    it "can be an admin" do
      user = create(:user, :admin)
      expect(user.admin?).to be true
      expect(user.resident?).to be false
    end

    it "can change roles" do
      barangay = create(:barangay)
      user = create(:user, barangay: barangay)
      expect(user.resident?).to be true

      user.barangay_official!
      expect(user.barangay_official?).to be true

      user.admin!
      expect(user.admin?).to be true
    end
  end

  describe "associations" do
    it "can belong to a barangay" do
      barangay = create(:barangay)
      user = create(:user, :barangay_official, barangay: barangay)
      expect(user.barangay).to eq(barangay)
    end

    it "resident requires a barangay" do
      barangay = create(:barangay)
      user = create(:user, barangay: barangay)
      expect(user.barangay).to eq(barangay)
    end
  end

  describe "devise modules" do
    it "is database authenticatable" do
      user = create(:user)
      expect(user.valid_password?("password123")).to be true
      expect(user.valid_password?("wrongpassword")).to be false
    end

    it "has confirmable module enabled" do
      expect(User.devise_modules).to include(:confirmable)
    end

    it "can be confirmed" do
      user = create(:user)
      expect(user.confirmed?).to be true
      expect(user.confirmed_at).not_to be_nil
    end
  end
end
