require 'mail'
require 'net/imap'

class MailAccount < ApplicationRecord

  crypt_keeper :login, :password , :encryptor => :aes_new, :key => 'gotMailSlaveToEncrypt', salt: 'salt'

  belongs_to :user
  has_many :user_mails

  def pull_imap
    conn = Net::IMAP.new(host, port, ssl)
    conn.login(login, password)
    conn.examine('INBOX')
    conn.search("SINCE 09-Oct-2017 SEEN").each do |message_id|
      next if UserMail.exists? :message_id => message_id

      # fetch all the email contents
      msg = conn.fetch(message_id,'RFC822')[0].attr['RFC822']
      # instantiate a UserMail object to avoid further IMAP parameters nightmares
      mail_obj = Mail.read_from_string msg
      plain_text = body_in_utf8(mail_obj,'text/plain')
      html_text = body_in_utf8(mail_obj,'text/html')
      m_subject = mail_obj.subject
      m_from = mail_obj.from
      m_to = mail_obj.to
      m_cc = mail_obj.cc
      m_bcc = mail_obj.bcc
      m_replyto = mail_obj.reply_to
      m_receive_date = mail_obj.date
      m_id = mail_obj.message_id
      m_in_reply_to = mail_obj.in_reply_to

      mail = self.user_mails.new(subject: m_subject,
                              from: m_from,
                              to: m_to,
                              receive_date: m_receive_date,
                              plain_content: plain_text,
                              html_content: html_text,
                              message_id: m_id,
                              mailbox_id: message_id,
                              cc: m_cc,
                              bcc: m_bcc,
                              replyto: m_replyto,
                              in_reply_to: m_in_reply_to
                             )
      if mail.save
        m_file = CarrierFile.new(mail_obj.to_s)
        m_file.original_filename = "mail_source_#{mail.id}.eml"
        m_file.content_type = mail_obj.mime_type
        mail.source_file = m_file
        mail.checksum = Digest::SHA2.hexdigest(mail_obj.to_s)
        mail.save!

        mail_obj.attachments.each do |att|
          document = CarrierFile.new(att.decoded)
          document.original_filename = att.filename
          document.content_type = att.mime_type
          mail.user_mail_attachments.create(file: document )
        end
      end
    end
    conn.logout
  end

  def get_attachments(message)
    return message.attachments.collect {|att| att.filename}
  end

  def body_in_utf8(message,content_type)
    if message.multipart?
      body_text = ""
      message.parts.each do |part_to_use|
        if part_to_use.content_type[content_type]
          encoding = part_to_use.content_type_parameters['charset'] if part_to_use.content_type_parameters
          body = part_to_use.body.decoded
          body = body.force_encoding(encoding).encode('UTF-8') if encoding
          body_text += body
        end
        if part_to_use.multipart?
          body_text += body_in_utf8(part_to_use,content_type)
        end
      end
      return body_text
    else
      part_to_use = message.find_first_mime_type(content_type)
      if part_to_use
        encoding = part_to_use.content_type_parameters['charset'] if part_to_use.content_type_parameters
        body = part_to_use.body.decoded
        body = body.force_encoding(encoding).encode('UTF-8') if encoding
        return body
      else
        return nil
      end
      #return message.decoded
    end

  end
end
