class AddFolderToUserMails < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :folder_id, :integer
  end
end
