class RemoveAttachedFilesFromUserMails < ActiveRecord::Migration[5.0]
  def change
    remove_column :user_mails, :attached_files
  end
end
