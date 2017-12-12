class CreateMailboxFolders < ActiveRecord::Migration[5.0]
  def change
    create_table :mailbox_folders do |t|
      t.string :name
      t.references :mail_account, foreign_key: true
      t.boolean :sync_active

      t.timestamps
    end
  end
end
