require 'rails_helper'

RSpec.describe Crono::CronoJob, type: :model,regressor: true do

  # === Relations ===
  
  
  

  # === Nested Attributes ===
  

  # === Database (Columns) ===
  it { is_expected.to have_db_column :id }
  it { is_expected.to have_db_column :job_id }
  it { is_expected.to have_db_column :log }
  it { is_expected.to have_db_column :last_performed_at }
  it { is_expected.to have_db_column :healthy }
  it { is_expected.to have_db_column :created_at }
  it { is_expected.to have_db_column :updated_at }

  # === Database (Indexes) ===
  

  # === Validations (Length) ===
  

  # === Validations (Presence) ===
  it { is_expected.to validate_presence_of :job_id }

  # === Validations (Numericality) ===
  

  
  # === Enums ===
  
  
end