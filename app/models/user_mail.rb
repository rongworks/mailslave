class UserMail < ApplicationRecord
  belongs_to :mail_account
  has_many :user_mail_attachments

  validates :mailbox_id, uniqueness: true

  #mount_uploader :source_content, MailSourceUploader

  def get_attachment(filename)
    mail = Mail.read_from_string(source_content)
    file = mail.attachments.detect {|att| att.filename == filename}
    return file.decoded
  end
end
