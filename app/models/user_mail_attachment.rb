class UserMailAttachment < ApplicationRecord
  belongs_to :user_mail
  mount_uploader :file, AttachedFileUploader

  def get_filename
    return "#{user_mail.id}_#{file.filename}"
  end

  def get_foldername
    return "#{user_mail.mail_account.email}/attachments"
  end
end
