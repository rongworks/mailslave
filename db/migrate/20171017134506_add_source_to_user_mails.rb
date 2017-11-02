class AddSourceToUserMails < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :source_content, :text
    add_column :user_mails, :plain_content, :text
    add_column :user_mails, :html_content, :text
  end
end
