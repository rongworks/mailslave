class AddSmtpServerToMailAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :mail_accounts, :smtp_server, :string
    add_column :mail_accounts, :smtp_port, :string
  end
end
