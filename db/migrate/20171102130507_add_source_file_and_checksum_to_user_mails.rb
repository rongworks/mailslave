class AddSourceFileAndChecksumToUserMails < ActiveRecord::Migration[5.0]
  def change
    add_column :user_mails, :source_file, :string
    add_column :user_mails, :checksum, :string
  end
end
