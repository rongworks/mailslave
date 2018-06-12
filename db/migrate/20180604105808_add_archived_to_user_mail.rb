class AddArchivedToUserMail < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :archived, :boolean
  end
end
