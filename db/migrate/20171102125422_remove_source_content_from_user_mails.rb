class RemoveSourceContentFromUserMails < ActiveRecord::Migration[5.0]
  def change
    remove_column :user_mails, :source_content
  end
end
