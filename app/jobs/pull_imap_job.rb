class PullImapJob < ApplicationJob
  queue_as :imap_sync

  def perform(*args)
    MailAccount.all.each do |account|
      account.delay.pull_imap(:queue => 'imap')
    end
  end
end
