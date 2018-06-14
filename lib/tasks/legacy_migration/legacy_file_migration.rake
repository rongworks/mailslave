namespace :legacy do

  namespace :files do

    desc 'Set upload path on old archived emails'
    task :set_upload_path => :environment do

      UserMail.all.each do |mail|
        id = mail.id
        p "Mail: #{id}"
        p "Original Path: #{mail.upload_path}"
        mail.upload_path = "uploads/user_mail/mail_source/#{id}/mail_source_#{id}.eml"
        mail.user_mail_attachments.each do |att|
          att.upload_path = "uploads/user_mail_attachment/file/#{id}/#{att.file_identifier}"
          att.save!
        end
        mail.save!
        p "Path: #{mail.upload_path}"
      end

    end

  end
end