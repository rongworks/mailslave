class SyncJob < ApplicationRecord
  belongs_to :mail_account

  before_create do
    self.processed_entries = 0
    self.new_entries = 0
    self.skipped_entries = 0
    self.archived_entries = 0
    self.info = ""
  end

  def reschedule
    mail_account.sync!
  end
end
