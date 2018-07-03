class ArchiveMailerPreview < ActionMailer::Preview
  def send_to_archive_mail
    account = MailAccount.first
    mail = account.user_mails.first
    mail_obj = Mail.read_from_string(mail.source_file.read)
    ArchiveMailer.with(from:account.email,to:to,subject:mail_obj.subject,attachment:mail_obj.to_s).send_to_archive_mail
  end
end