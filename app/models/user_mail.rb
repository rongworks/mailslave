class UserMail < ApplicationRecord
  belongs_to :mail_account, :inverse_of => :user_mails
  belongs_to :mailbox_folder, :inverse_of => :user_mails, foreign_key: :folder_id
  has_many :user_mail_attachments, dependent: :destroy

  validates :message_id, uniqueness: true
  validates :plain_content,:html_content, length: {maximum: 2621000}
  validates :message_id,:to,:from,presence: true

  before_save :upload_location
  before_validation :check_receiver

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

  def get_filename
    sbj_name = subject.blank? ? "(No Subject)":subject.gsub(/[^0-9A-z.\-]/, '_').truncate(25, omission:'__')
    return "#{id}_#{sbj_name}.eml"
  end

  private
  def upload_location
    upload_path = self.upload_path || ''

    file_path = self.source_file.path unless self.source_file.file.nil?

    if self.source_file.present?
      self.upload_path=file_path
    elsif File.exists?(upload_path) && file_path
      File.makedirs(File.dirname(upload_path))
      File.rename(upload_path, file_path)
      self.upload_path = file_path
    else
      Rails.logger.error("File for attachment #{id} cannot be found")
      # TODO: rescan mail?
    end
  end

  def check_receiver
    if self.to.nil?
      self.to = mail_account.email
    end
  end

end
