namespace :sync do

  desc 'Start sync jobs'
  task :start => :environment do

    MailAccount.all.each do |account|
      account.sync!
    end

  end


end