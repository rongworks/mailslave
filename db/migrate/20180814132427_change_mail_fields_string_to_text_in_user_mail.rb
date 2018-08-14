class ChangeMailFieldsStringToTextInUserMail < ActiveRecord::Migration[5.0]
  def up
    change_column :user_mails, :cc, :text
    change_column :user_mails, :bcc, :text
    change_column :user_mails, :to, :text
  end

  def down
    change_column :user_mails, :cc, :string
    change_column :user_mails, :bcc, :string
    change_column :user_mails, :to, :string
  end
end
