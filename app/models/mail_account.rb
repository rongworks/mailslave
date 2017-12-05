require 'mail'
require 'net/imap'

class MailAccount < ApplicationRecord

  crypt_keeper :login, :password , encryptor: :aes_new, key: 'gotMailSlaveToEncrypt', salt: 'salt'

  belongs_to :user
  has_many :user_mails

  has_settings do |setting|
    setting.key :sync_options, defaults: {
      interval: 100800, # interval for retrieving TODO: implement
      only_seen: true, # only seen messages get archived
      only_older_than: 7, # only archive messages older than X days
      delete_after: 30, # delete messages that are older than x days TODO: implement
      exclude_folders: '[]' # list of folders, that are not archived TODO: implement
    }
  end

  def pull_imap
    imap = Net::IMAP.new(host, port, ssl)
    imap.login(login, password)

    search_query = ['UNFLAGGED']
    search_query << 'SEEN' if settings(:sync_options).only_seen
    search_query << "BEFORE"
    search_query << (Date.today - settings(:sync_options).only_older_than).strftime('%d-%b-%Y')

    folder_list = imap.list('','*').collect {|mbox| mbox.name}
    # TODO: filter folder_list for excluded folders
    folder_list.each do |folder|
      logger.info "searching mailbox #{folder} for account #{name}"
      import_folder(imap,folder, search_query)
    end
    imap.logout
    imap.disconnect
  end

  def import_folder(imap,folder,search_query)
    imap.examine(folder)
    imap.search(search_query).each do |message_id|
      logger.info "Processing #{message_id}"

      # fetch all the email contents
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
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

      if UserMail.exists?(:message_id => m_id)
        logger.info "Existing mail #{m_id} skipped"
        next
      end

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
      # TODO: mark processed as FLAGGED
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
      else
        logger.error(mail.errors.full_messages)
      end
    end
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
