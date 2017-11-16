class MailAccountPolicy < ApplicationPolicy
  def pull_imap?
    true
  end
  def new?
    true
  end
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
