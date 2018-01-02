class ChangeReceivedDateInDatetimeForUserMails < ActiveRecord::Migration[5.0]
  def up
    change_column :user_mails, :receive_date, :datetime
  end

  def down
    change_column :user_mails, :receive_date, :date
  end
end
