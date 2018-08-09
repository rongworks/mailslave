# Migrated to rake task
#MailAccount.all.each do |account|
#  account.delay(:queue => 'sync', run_at:2.seconds).pull_imap
#end