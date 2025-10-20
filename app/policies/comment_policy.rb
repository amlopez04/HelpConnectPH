class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  def create?
    user.present? # Must be logged in to comment
  end
  
  def destroy?
    user.present? && (record.user == user || user.admin?)
  end
end

