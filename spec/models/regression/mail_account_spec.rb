require 'rails_helper'

RSpec.describe MailAccount, regressor: true do

  # === Relations ===
  it { is_expected.to belong_to :user }
  
  it { is_expected.to have_many :user_mails }

  # === Nested Attributes ===
  

  # === Database (Columns) ===
  it { is_expected.to have_db_column :id }
  it { is_expected.to have_db_column :name }
  it { is_expected.to have_db_column :email }
  it { is_expected.to have_db_column :user_id }
  it { is_expected.to have_db_column :login }
  it { is_expected.to have_db_column :password }
  it { is_expected.to have_db_column :port }
  it { is_expected.to have_db_column :ssl }
  it { is_expected.to have_db_column :host }
  it { is_expected.to have_db_column :created_at }
  it { is_expected.to have_db_column :updated_at }

  # === Database (Indexes) ===
  it { is_expected.to have_db_index ["user_id"] }

  # === Validations (Length) ===
  

  # === Validations (Presence) ===
  

  # === Validations (Numericality) ===
  

  
  # === Enums ===
  
  
end