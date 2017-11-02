class CreateMailAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :mail_accounts do |t|
      t.string :name
      t.string :email
      t.references :user, foreign_key: true
      t.string :login
      t.string :password
      t.string :port
      t.boolean :ssl
      t.string :host

      t.timestamps
    end
  end
end
