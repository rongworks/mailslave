class MailboxFolder < ApplicationRecord
  belongs_to :mail_account
  has_many :user_mails
end
