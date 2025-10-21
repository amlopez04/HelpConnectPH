class ReportPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        # Admins see all reports
        scope.all
      elsif user.barangay_official? && user.barangay.present?
        # Barangay officials only see reports from their barangay
        scope.where(barangay_id: user.barangay_id)
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
    
    # Barangay officials can only view reports from their barangay
    if user.barangay_official? && user.barangay.present?
      record.barangay_id == user.barangay_id
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
    
    # Report creator can update their own report
    return true if record.user == user
    
    # Admin can update any report
    return true if user.admin?
    
    # Barangay official can only update reports from their barangay
    if user.barangay_official? && user.barangay.present?
      record.barangay_id == user.barangay_id
    else
      false
    end
  end
  
  def edit?
    update?
  end
  
  def destroy?
    user.present? && (record.user == user || user.admin?)
  end
end

