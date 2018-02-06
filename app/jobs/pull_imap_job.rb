class PullImapJob < ApplicationJob
  queue_as :imap_sync

  def perform(*args)
    MailAccount.all.each do |account|
      account.delay(:queue => 'imap').pull_imap
    end
  end
end
