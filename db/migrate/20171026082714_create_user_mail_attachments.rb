class CreateUserMailAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :user_mail_attachments do |t|
      t.references :user_mail, foreign_key: true
      t.string :file

      t.timestamps
    end
  end
end
