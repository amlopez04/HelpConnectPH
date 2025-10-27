require 'rails_helper'

RSpec.describe Report, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      report = build(:report)
      expect(report).to be_valid
    end

    it "requires a title" do
      report = build(:report, title: nil)
      expect(report).not_to be_valid
      expect(report.errors[:title]).to include("can't be blank")
    end

    it "requires a description" do
      report = build(:report, description: nil)
      expect(report).not_to be_valid
      expect(report.errors[:description]).to include("can't be blank")
    end

    it "requires an address" do
      report = build(:report, address: nil)
      expect(report).not_to be_valid
      expect(report.errors[:address]).to include("can't be blank")
    end

    it "requires a user" do
      report = build(:report, user: nil)
      expect(report).not_to be_valid
      expect(report.errors[:user]).to include("must exist")
    end

    it "requires a barangay" do
      report = build(:report, barangay: nil)
      expect(report).not_to be_valid
      expect(report.errors[:barangay]).to include("must exist")
    end

    it "requires a category" do
      report = build(:report, category: nil)
      expect(report).not_to be_valid
      expect(report.errors[:category]).to include("must exist")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      report = create(:report, user: user)
      expect(report.user).to eq(user)
    end

    it "belongs to a barangay" do
      barangay = create(:barangay)
      report = create(:report, barangay: barangay)
      expect(report.barangay).to eq(barangay)
    end

    it "belongs to a category" do
      category = create(:category)
      report = create(:report, category: category)
      expect(report.category).to eq(category)
    end
  end

  describe "status enum" do
    it "defines status enum correctly" do
      expect(Report.statuses.keys).to match_array([ "pending", "in_progress", "resolved", "closed" ])
    end

    it "defaults to pending status" do
      report = create(:report)
      expect(report.pending?).to be true
    end

    it "can be in_progress" do
      report = create(:report, :in_progress)
      expect(report.in_progress?).to be true
    end

    it "can be resolved" do
      report = create(:report, :resolved)
      expect(report.resolved?).to be true
    end

    it "can be closed" do
      report = create(:report, :closed)
      expect(report.closed?).to be true
    end

    it "can change status" do
      report = create(:report)
      expect(report.pending?).to be true

      report.in_progress!
      expect(report.in_progress?).to be true

      report.resolved!
      expect(report.resolved?).to be true

      report.closed!
      expect(report.closed?).to be true
    end
  end

  describe "priority enum" do
    it "defines priority enum correctly" do
      expect(Report.priorities.keys).to match_array([ "low", "medium", "high", "critical" ])
    end

    it "defaults to medium priority" do
      report = create(:report)
      expect(report.medium?).to be true
    end

    it "can be low priority" do
      report = create(:report, :low_priority)
      expect(report.low?).to be true
    end

    it "can be high priority" do
      report = create(:report, :high_priority)
      expect(report.high?).to be true
    end

    it "can be critical priority" do
      report = create(:report, :critical_priority)
      expect(report.critical?).to be true
    end
  end

  describe "geocoding" do
    it "has latitude" do
      report = create(:report)
      expect(report.latitude).not_to be_nil
    end

    it "has longitude" do
      report = create(:report)
      expect(report.longitude).not_to be_nil
    end
  end

  describe "resolved_at timestamp" do
    it "can have a resolved_at timestamp" do
      report = create(:report, :resolved)
      expect(report.resolved_at).not_to be_nil
    end

    it "doesn't have resolved_at when pending" do
      report = create(:report, :pending)
      expect(report.resolved_at).to be_nil
    end
  end

  describe "photo attachments" do
    it "can have many photos attached" do
      report = create(:report)
      expect(report.photos).to respond_to(:attach)
      expect(report.photos).to respond_to(:attached?)
    end

    it "can attach multiple photos" do
      report = create(:report)
      # Simulate attaching photos using Active Storage
      report.photos.attach(
        io: StringIO.new("fake image content"),
        filename: "test1.jpg",
        content_type: "image/jpeg"
      )
      report.photos.attach(
        io: StringIO.new("fake image content 2"),
        filename: "test2.jpg",
        content_type: "image/jpeg"
      )

      expect(report.photos.count).to eq(2)
      expect(report.photos.first.filename.to_s).to eq("test1.jpg")
      expect(report.photos.second.filename.to_s).to eq("test2.jpg")
    end
  end
end
