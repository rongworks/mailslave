class UserMailPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.user_mails
      end
    end
  end
end
