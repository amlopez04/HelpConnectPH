class ReportPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins see all reports
        scope.all
      elsif user.barangay_official? && user.barangay.present?
        # Barangay officials only see approved reports from their barangay
        scope.where(barangay_id: user.barangay_id).where.not(status: :pending_approval)
      else
        # Residents see all reports (to view community issues)
        scope.all
      end
    end
  end

  def index?
    true # Anyone can view reports list (filtered by scope)
  end

  def show?
    # Admins and residents can view any report
    return true if user.admin? || user.resident?

    # Barangay officials can only view approved reports from their barangay
    if user.barangay_official? && user.barangay.present?
      record.barangay_id == user.barangay_id && record.status != :pending_approval
    else
      false
    end
  end

  def create?
    user.present? && !user.admin? # Logged in users except admins can create
  end

  def new?
    create?
  end

  def update?
    return false unless user.present?

    # Cannot update closed or resolved reports (except admins)
    return false if (record.closed? || record.resolved?) && !user.admin?

    # Residents can only edit reports that are still pending_approval
    # Once approved (status is pending or beyond), they cannot edit
    if user.resident? && record.user == user
      # Explicitly allow editing only when status is pending_approval
      return record.pending_approval?
    end

    # Admin can update any report
    return true if user.admin?

    # Barangay official can only update reports from their barangay (if not closed or resolved)
    if user.barangay_official? && user.barangay.present?
      record.barangay_id == user.barangay_id && !record.closed? && !record.resolved?
    else
      false
    end
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user.present?

    # Cannot delete closed reports (except admins)
    return false if record.closed? && !user.admin?

    # Residents can only delete reports that are still pending_approval
    # Once approved (status is pending or beyond), they cannot delete
    if user.resident? && record.user == user
      return false if record.status != :pending_approval
      return true if record.pending_approval?
    end

    # Admin can delete any report
    return true if user.admin?

    false
  end

  def request_reopen?
    return false unless user.present?

    # Only residents can request to reopen their own closed or resolved reports
    user.resident? && record.user == user && (record.closed? || record.resolved?)
  end
end
