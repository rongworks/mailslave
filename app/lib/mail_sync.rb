require 'net/imap'
require 'mail'

class MailSync
  attr_accessor :account, :imap, :cnt_mails_skipped, :cnt_mails_processed, :cnt_mails_new

  def initialize(account)
    self.account = account
    self.imap = Net::IMAP.new(account.host, account.port, account.ssl)
    self.imap.login(account.login, account.password)
  end

  def sync(folder_excludes, search_query)

    start_time = Time.now
    @cnt_mails_new = 0
    @cnt_mails_processed = 0
    @cnt_mails_skipped = 0

    folder_list = imap.list('','*').collect {|mbox| mbox.name}
    # TODO: filter folder_list for excluded folders
    folder_list.each do |folder|
      Rails.logger.info message:"searching mailbox", query: search_query, account: account.id, mailbox:folder
      acc_folder = account.find_or_create_folder(folder)

      import_folder(folder, acc_folder.id, search_query)
      Rails.logger.info "Sync job complete:
                        #{@cnt_mails_processed} mails processed |
                        #{@cnt_mails_skipped} mails skipped |
                        #{@cnt_mails_new} new mails archived !"
      end_time = Time.now
      sync_job = account.build_sync_job({
              sync_start:start_time,
              sync_end: end_time,
              processed_entries: @cnt_mails_processed,
              new_entries: @cnt_mails_new,
              skipped_entries: @cnt_mails_skipped
          })
      account.save!
    end
  end

  def import_folder(folder,folder_id,search_query)
    imap.examine(folder)
    imap.search(search_query).each do |message_id|
      Rails.logger.debug message:"Processing #{message_id}",mailbox:folder

      # fetch all the email contents
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      # instantiate a UserMail object to avoid further IMAP parameters nightmares
      mail_obj = Mail.read_from_string msg
      contents = parse_body(mail_obj)
      plain_text = contents['text/plain'].truncate(2621000)
      html_text = contents['text/html'].truncate(2621000)
      #plain_text = body_in_utf8(mail_obj,'text/plain').truncate(20000)
      #html_text = body_in_utf8(mail_obj,'text/html').truncate(20000)
      m_subject = mail_obj.subject
      m_from = mail_obj.from
      m_to = mail_obj.to
      m_cc = mail_obj.cc
      m_bcc = mail_obj.bcc
      m_replyto = mail_obj.reply_to
      m_receive_date = mail_obj.date
      m_id = mail_obj.message_id
      m_in_reply_to = mail_obj.in_reply_to

      attrs = {subject: m_subject,
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
               in_reply_to: m_in_reply_to,
               conversation: mail_obj.references,
               folder_id: folder_id}

      if UserMail.exists?(:message_id => m_id)
        Rails.logger.debug "Existing mail #{m_id} skipped"
        @cnt_mails_skipped += 1
        next
      else
        @cnt_mails_processed += 1
      end

      mail = account.user_mails.new(attrs)
      # TODO: mark processed as FLAGGED
      if mail.save
        @cnt_mails_new += 1
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
        Rails.logger.error(mail.errors.full_messages)
      end
    end
  end

  def disconnect
    imap.logout
    imap.disconnect
  end

  def get_attachments(message)
    return message.attachments.map(&:filename)
  end

  def parse_body(message)
    contents = {}
    if message.multipart?
      message.parts.each do |part|
        contents.merge!(parse_body(part)){|key, oldval, newval| oldval + newval}
      end
    else
      content_type_full = message.content_type
      #encoding = message.content_type_parameters['charset']
      if content_type_full.blank?
        content_type = 'other'
      else
        splitted = content_type_full.split(';')
        content_type = splitted[0] unless splitted.length < 1
      end
      contents[content_type] = message.decoded
    end
    return contents
  end

=begin TODO:  Safe Delete
  def body_in_utf8(message,content_type)
    if message.multipart?
      body_text = ''
      message.parts.each do |part_to_use|
        if part_to_use.content_type[content_type]
          encoding = part_to_use.content_type_parameters['charset'] if part_to_use.content_type_parameters
          body = part_to_use.body.decoded
          if check_encoding(encoding)
            body = body.force_encoding(encoding).encode('UTF-8')
          else
            body = body.force_encoding('UTF-8').encode('UTF-8')
          end
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
        if check_encoding(encoding)
          body = body.force_encoding(encoding).encode('UTF-8')
        else
          body = body.force_encoding('UTF-8').encode('UTF-8')
        end
        return body
      elsif message.body
        return message.body.decoded.force_encoding("UTF-8")
      else
        Rails.logger.warn "No message detected in #{message.message_id} for #{content_type}"
        return nil
      end
      #return message.decoded
    end

  end
=end

  def check_encoding(encoding_str)
    Encoding.name_list.any?{ |encoding| encoding.casecmp(encoding_str).zero? }
  end

end