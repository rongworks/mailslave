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
    if self.file.present?
      file_path = self.file.path
      if upload_path != file_path
        if File.exists?(upload_path)
          File.rename(upload_path, file_path)
        elsif File.exists?(file_path)
          self.upload_path = file_path
        else
          Rails.logger.error("File for attachment #{id} cannot be found")
          # TODO: Bad, raise exception
        end
        self.upload_path = file_path
      end
    end
  end
end
