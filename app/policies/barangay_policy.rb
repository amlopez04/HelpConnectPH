class BarangayPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def index?
    # Only admins and residents can browse all barangays
    # Barangay officials should focus on their own barangay only
    user&.admin? || user&.resident?
  end
  
  def show?
    # Admins and residents can view any barangay
    return true if user&.admin? || user&.resident?
    
    # Barangay officials can only view their own barangay
    if user&.barangay_official? && user.barangay.present?
      record.id == user.barangay_id
    else
      false
    end
  end
  
  def create?
    user&.admin? # Only admins can create
  end
  
  def new?
    create?
  end
  
  def update?
    user&.admin? # Only admins can update
  end
  
  def edit?
    update?
  end
  
  def destroy?
    user&.admin? # Only admins can delete
  end
end

