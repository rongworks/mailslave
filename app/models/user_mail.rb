class UserMail < ApplicationRecord
  belongs_to :mail_account
  belongs_to :mailbox_folder
  has_many :user_mail_attachments, dependent: :destroy

  validates :message_id, uniqueness: true
  validates :plain_content,:html_content, length: {maximum: 2621000}

  mount_uploader :source_file, MailSourceUploader

  ransack_alias :quicksearch, :subject_or_html_content_or_plain_content_or_from_or_to_or_cc_or_bcc

  def get_attachment(filename)
    mail = Mail.read_from_string(source_content)
    file = mail.attachments.detect {|att| att.filename == filename}
    return file.decoded
  end

  def source_content
    File.read(source_file.file.file)
  end

  def has_html?
    html_content && html_content.include?('<html>')
  end

  def has_text?
    plain_content.present?
  end
end
