# Preview all emails at http://localhost:3000/rails/mailers/archive_mailer
class ArchiveMailerPreview < ActionMailer::Preview
  def send_to_archive_mail
    to = 'mailslave-archive@kaiser-tappe.de'
    account = MailAccount.first
    mail = account.user_mails.first
    mail_obj = Mail.read_from_string(mail.source_file.read)
    ArchiveMailer.send_to_archive_mail({from:account.email,to:to,subject:mail_obj.subject,attachment:mail_obj.to_s})
  end
end
