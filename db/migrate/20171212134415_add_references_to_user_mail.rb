class AddReferencesToUserMail < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :references, :text
  end
end
