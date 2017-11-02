class UserMailAttachment < ApplicationRecord
  belongs_to :user_mail
  mount_uploader :file, AttachedFileUploader
end
