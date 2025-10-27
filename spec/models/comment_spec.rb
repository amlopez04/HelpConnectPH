require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it "requires content" do
      comment = build(:comment, content: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to include("can't be blank")
    end

    it "requires a user" do
      comment = build(:comment, user: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to include("must exist")
    end

    it "requires a report" do
      comment = build(:comment, report: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:report]).to include("must exist")
    end

    it "validates content is not too short" do
      comment = build(:comment, content: "Hi")
      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to include("is too short (minimum is 3 characters)")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      comment = create(:comment, user: user)
      expect(comment.user).to eq(user)
    end

    it "belongs to a report" do
      report = create(:report)
      comment = create(:comment, report: report)
      expect(comment.report).to eq(report)
    end
  end

  describe "ordering" do
    it "orders comments by created_at ascending (oldest first)" do
      report = create(:report)
      comment3 = create(:comment, report: report, created_at: 3.hours.ago)
      comment1 = create(:comment, report: report, created_at: 5.hours.ago)
      comment2 = create(:comment, report: report, created_at: 4.hours.ago)

      expect(Comment.all).to eq([ comment1, comment2, comment3 ])
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      comment = create(:comment)
      expect(comment.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      comment = create(:comment)
      expect(comment.updated_at).not_to be_nil
    end
  end
end
