json.extract! mail_account, :id, :name, :email, :user_id, :port, :ssl, :host, :created_at, :updated_at
json.url mail_account_url(mail_account, format: :json)
