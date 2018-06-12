require 'net/imap'
require 'mail'

class MailSync
  attr_accessor :account, :imap, :cnt_mails_skipped, :cnt_mails_processed, :cnt_mails_new, :cnt_mails_archived, :sync_info

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
    @cnt_mails_archived = 0
    @sync_info = ''

    folder_list = imap.list('','*').collect {|mbox| mbox.name} - folder_excludes
    folder_list.each do |folder|
      Rails.logger.info message:"searching mailbox #{folder}", query: search_query, account: account.id, mailbox:folder
      acc_folder = account.find_or_create_folder(folder)
      begin
        import_folder(folder, acc_folder.id, search_query)
      rescue StandardError => e
        Rails.logger.error "Sync of #{folder} failed.\n #{e.message}"
        @sync_info += "Sync of #{folder} failed.\n #{e.message} \n"
      end
    end
    Rails.logger.info "Sync job complete:
                        #{@cnt_mails_processed} mails processed |
                        #{@cnt_mails_skipped} mails skipped |
                        #{@cnt_mails_new} new mails |
                        #{@cnt_mails_archived} mails archived !"
    end_time = Time.now
    sync_job = account.build_sync_job({
                                          sync_start:start_time,
                                          sync_end: end_time,
                                          processed_entries: @cnt_mails_processed,
                                          new_entries: @cnt_mails_new,
                                          skipped_entries: @cnt_mails_skipped,
                                          archived_entries: @cnt_mails_archived,
                                          info: @sync_info
                                      })
    account.save!
  end

  def import_folder(folder,folder_id,search_query)
    imap.select(folder)
    archive_folder_name = account.settings(:sync_options).archive_folder_name
    imap.create(archive_folder_name) if imap.list('',archive_folder_name).nil?
    imap.search(search_query).each do |message_id|
      Rails.logger.debug message:"Processing #{message_id}",mailbox:folder
      @cnt_mails_processed += 1

      # fetch all the email contents
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      # instantiate a UserMail object to avoid further IMAP parameters nightmares
      mail_obj = Mail.read_from_string msg
      contents = parse_body(mail_obj)
      plain_text = contents['text/plain'].try(:truncate,2621000)
      html_text = contents['text/html'].try(:truncate,2621000)

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

      due_date = m_receive_date + account.settings(:sync_options).delete_after.days
      archive = Date.today > due_date

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
               folder_id: folder_id,
               archived: archive}

      m_desc = "#{message_id} / #{m_subject.truncate(25)}"
      # TODO: if exist, compare checksums
      if UserMail.exists?(:message_id => m_id)
        Rails.logger.info "Existing mail #{m_id} skipped"
        @cnt_mails_skipped += 1
        @sync_info += "#{folder}:#{m_desc} - existing entry \n"
        mail = UserMail.where(message_id: m_id).first
      else
        mail = account.user_mails.new(attrs)
        if mail.save
          @cnt_mails_new += 1
          @sync_info += "#{folder}:#{m_desc} - new entry \n"
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
          Rails.logger.error(mail.errors.full_messages + mail.inspect)
          raise mail.errors.full_messages
        end
      end


      Rails.logger.info("Mail #{mail.id}: received:#{mail.receive_date} due:#{due_date}")
      if archive
        if mail.archived?
          Rails.logger.warn("Mail #{mail.id} was archived but not moved to archive")
        end
        Rails.logger.info("Deleting old mail #{mail.subject.truncate(20)} #{mail.id} received on #{mail.receive_date}, due on #{due_date}")
        imap.copy(message_id, archive_folder_name)
        imap.store(message_id, "+FLAGS", [:Deleted])
        mail.update_attribute(:archived, true)
        @cnt_mails_archived += 1
        @sync_info += "#{folder}:#{m_desc} - archived \n"
      end
    end
    imap.expunge
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


  def check_encoding(encoding_str)
    Encoding.name_list.any?{ |encoding| encoding.casecmp(encoding_str).zero? }
  end

end