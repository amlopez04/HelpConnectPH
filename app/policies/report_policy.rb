class ReportPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def index?
    true # Anyone can view reports list
  end
  
  def show?
    true # Anyone can view a report
  end
  
  def create?
    user.present? # Must be logged in to create
  end
  
  def new?
    create?
  end
  
  def update?
    user.present? && (record.user == user || user.admin? || user.barangay_official?)
  end
  
  def edit?
    update?
  end
  
  def destroy?
    user.present? && (record.user == user || user.admin?)
  end
end

