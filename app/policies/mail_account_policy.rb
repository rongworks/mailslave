class MailAccountPolicy < ApplicationPolicy
  def pull_imap?
    true
  end
  def new?
    true
  end
  def create?
    true
  end
  def edit?
    user.id == record.user_id || user.admin?
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
