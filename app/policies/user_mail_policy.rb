class UserMailPolicy < ApplicationPolicy
  def download_attachment?
    !user.present?
  end
  class Scope < Scope
    def resolve
      if user && user.admin?
        scope
      else
        scope #TODO: Limit to user
      end
    end
  end
end
