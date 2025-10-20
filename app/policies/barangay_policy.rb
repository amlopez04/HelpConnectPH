class BarangayPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def index?
    true # Anyone can view barangays
  end
  
  def show?
    true # Anyone can view a barangay
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

