class MailAccountPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.mail_accounts
      end
    end
  end
end
