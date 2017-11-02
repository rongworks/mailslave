class CreateMails < ActiveRecord::Migration[5.0]
  def change
    create_table :user_mails do |t|
      t.string :from
      t.string :to
      t.string :replyto
      t.date :receive_date
      t.string :envelope_from
      t.string :message_id
      t.string :cc
      t.string :bcc
      t.text :body
      t.string :subject
      t.integer :mail_account_id

      t.timestamps
    end
  end
end
