require 'rails_helper'

RSpec.describe UserMail, regressor: true do

  # === Relations ===
  it { is_expected.to belong_to :mail_account }
  
  it { is_expected.to have_many :user_mail_attachments }

  # === Nested Attributes ===
  

  # === Database (Columns) ===
  it { is_expected.to have_db_column :id }
  it { is_expected.to have_db_column :from }
  it { is_expected.to have_db_column :to }
  it { is_expected.to have_db_column :replyto }
  it { is_expected.to have_db_column :receive_date }
  it { is_expected.to have_db_column :envelope_from }
  it { is_expected.to have_db_column :message_id }
  it { is_expected.to have_db_column :cc }
  it { is_expected.to have_db_column :bcc }
  it { is_expected.to have_db_column :subject }
  it { is_expected.to have_db_column :mail_account_id }
  it { is_expected.to have_db_column :created_at }
  it { is_expected.to have_db_column :updated_at }
  it { is_expected.to have_db_column :mailbox_id }
  it { is_expected.to have_db_column :source_content }
  it { is_expected.to have_db_column :plain_content }
  it { is_expected.to have_db_column :html_content }
  it { is_expected.to have_db_column :attached_files }

  # === Database (Indexes) ===
  

  # === Validations (Length) ===
  

  # === Validations (Presence) ===
  

  # === Validations (Numericality) ===
  

  
  # === Enums ===
  
  
end