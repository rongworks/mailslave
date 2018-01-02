class RenameReferencesInUserMails < ActiveRecord::Migration[5.0]
  def change
    rename_column :user_mails, :references, :conversation
  end
end
