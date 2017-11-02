class RenameMailToUserMail < ActiveRecord::Migration[5.0]
  def change
    rename_table :mails, :user_mails
  end
end
