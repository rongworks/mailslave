require "rails_helper"

RSpec.describe ArchiveMailer, type: :mailer do

  describe 'archive_mail' do
    #TODO: No test data
    to = 'mailslave-archive@kaiser-tappe.de'
    account = MailAccount.first
    mail = account.user_mails.first
    mail_obj = Mail.read_from_string(mail.source_file.read)
    let (:mail) {ArchiveMailerPreview.send_to_archive_mail({from:account.email,to:to,subject:mail_obj.subject,attachment:mail_obj.to_s})}

    it 'contains mail source' do
      mail.attachments.should have(1).attachment
      attachment = mail.attachments[0]
      attachment.should be_a_kind_of(Mail::Part)
      #attachment.content_type.should be_start_with('application/ics;')
      #attachment.filename.should == 'event.ics'
    end
  end
end
