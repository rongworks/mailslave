require 'rails_helper'

RSpec.describe UserMailsController, regressor: true, type: :controller do
  # === Routes (REST) ===
  
  # === Callbacks (Before) ===
  it { should use_before_filter(:set_turbolinks_location_header_from_session) }
  it { should use_before_filter(:verify_authenticity_token) }
  it { should use_before_filter(:set_mail) }
  it { should use_before_filter(:authenticate_user!) }
  # === Callbacks (After) ===
  it { should use_after_filter(:verify_same_origin_request) }
  # === Callbacks (Around) ===
  
end