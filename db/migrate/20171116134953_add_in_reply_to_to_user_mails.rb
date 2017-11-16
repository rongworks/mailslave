class AddInReplyToToUserMails < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :in_reply_to, :string
  end
end
