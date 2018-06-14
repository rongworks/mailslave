class AddUploadPathToUserMail < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :upload_path, :string
  end
end
