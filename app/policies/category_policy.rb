class CategoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def index?
    # Only admins and residents can browse all categories
    # Barangay officials don't need to manage categories
    user&.admin? || user&.resident?
  end
  
  def show?
    # Only admins and residents can view category details
    user&.admin? || user&.resident?
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

