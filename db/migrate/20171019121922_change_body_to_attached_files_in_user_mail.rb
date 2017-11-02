class ChangeBodyToAttachedFilesInUserMail < ActiveRecord::Migration[5.0]
  def change
    remove_column :user_mails, :body
    add_column :user_mails, :attached_files, :string

  end
end
