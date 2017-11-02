json.extract! user_mail, :id, :from, :to, :replyto, :receive_date, :envelope_from, :message_id, :cc, :bcc, :body, :subject, :created_at, :updated_at
json.url user_mail_url(user_mail, format: :json)
