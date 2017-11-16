class ChangeLoginAndPasswordToTextInMailAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :mail_accounts, :login
    remove_column :mail_accounts, :password
    add_column :mail_accounts, :login, :text
    add_column :mail_accounts, :password, :text
  end
end
