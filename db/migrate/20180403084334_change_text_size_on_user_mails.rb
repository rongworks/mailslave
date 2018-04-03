class ChangeTextSizeOnUserMails < ActiveRecord::Migration[5.0]
  def change
    change_column :user_mails, :plain_content, :text, :limit => 10.megabytes
    change_column :user_mails, :html_content, :text, :limit => 10.megabytes
  end
end
