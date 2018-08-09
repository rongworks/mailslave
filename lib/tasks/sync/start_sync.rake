namespace :sync do

  desc 'Start sync jobs'
  task :start => :environment do

    MailAccount.all.each do |account|
      account.delay(:queue => 'sync').pull_imap
    end

  end


end