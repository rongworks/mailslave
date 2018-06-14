class AddUploadPathToUserMailAttachment < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mail_attachments, :upload_path, :string
  end
end
