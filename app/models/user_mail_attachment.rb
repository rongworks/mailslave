class UserMailAttachment < ApplicationRecord
  belongs_to :user_mail
  mount_uploader :file, AttachedFileUploader

  before_save :upload_location

  def filename
    file_identifier
  end

  def get_filename
    return "#{user_mail.id}_#{filename}"
  end

  def get_foldername
    return "#{user_mail.mail_account.email}/attachments"
  end

  private
  def upload_location
    upload_path = self.upload_path || ''
    file_path = self.file.path unless self.file.file.nil?

    if self.file.present?
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
end
