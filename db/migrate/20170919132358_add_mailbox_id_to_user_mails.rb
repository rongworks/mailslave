class AddMailboxIdToUserMails < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :mailbox_id, :string
  end
end
