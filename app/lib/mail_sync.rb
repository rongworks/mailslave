require 'net/imap'
require 'mail'

class MailSync
  attr_accessor :account, :imap, :cnt_mails_skipped, :cnt_mails_processed, :cnt_mails_new, :cnt_mails_archived, :sync_info, :entry_limit

  def initialize(account, entry_limit)
    self.account = account
    self.imap = Net::IMAP.new(account.host, account.port, account.ssl)
    self.imap.login(account.login, account.password)
    self.entry_limit = entry_limit
  end

  def sync(folder_excludes, search_query)
    account = self.account
    Mail.defaults do
      delivery_method :smtp, address: account.smtp_server, port: account.smtp_port
    end

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
      #  raise e
      end
    end
    msg = "Sync job complete:
                        #{@cnt_mails_processed} mails processed |
                        #{@cnt_mails_skipped} mails skipped |
                        #{@cnt_mails_new} new mails |
                        #{@cnt_mails_archived} mails archived !"
    Rails.logger.info msg
    @sync_info += msg

    end_time = Time.now
    sync_job = account.sync_jobs.create({
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
    errors = {}
    max_errors = 5

    imap.select(folder)
    archive_folder_name = account.settings(:sync_options).archive_folder_name
    imap.create(archive_folder_name) if imap.list('',archive_folder_name).nil?
    imap.search(search_query).each do |message_id|
      raise errors.inspect if errors.length >= max_errors
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      uid = imap.fetch(message_id,'UID')[0].attr['UID']
      begin
        sync_mail(msg, message_id, folder, folder_id)
      rescue StandardError => e
        errors[message_id] = "#{e} #{e.backtrace.first}\n"
        Rails.logger.error "#{e} #{e.backtrace}\n"
        @sync_info += "[#{folder}/#{uid}] #{e} #{e.backtrace.first}\n"
      #  raise e
      end
      break if @cnt_mails_archived >= entry_limit
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

  private
  def mail_from_string(message_id, folder_id, mail_obj)
    contents = parse_body(mail_obj)
    plain_text = contents['text/plain'].try(:truncate, 2621000)
    html_text = contents['text/html'].try(:truncate, 2621000)

    attrs = {subject: mail_obj.subject,
             from: mail_obj.from,
             to: mail_obj.to,
             receive_date: mail_obj.date,
             plain_content: plain_text,
             html_content: html_text,
             message_id: mail_obj.message_id,
             mailbox_id: message_id,
             cc: mail_obj.cc,
             bcc: mail_obj.bcc,
             replyto: mail_obj.reply_to,
             in_reply_to: mail_obj.in_reply_to,
             conversation: mail_obj.references,
             folder_id: folder_id,
             archived: false}
    return UserMail.new(attrs)
  end

  def store_source_file(mail_obj, mail)
    m_file = CarrierFile.new(mail_obj.to_s)
    m_file.original_filename = mail.get_filename
    m_file.content_type = mail_obj.mime_type
    mail.source_file = m_file
    mail.checksum = Digest::SHA2.hexdigest(mail_obj.to_s)
    mail.save!
  end

  def store_attachment_files(mail_obj, mail)
    mail_obj.attachments.each do |att|
      document = CarrierFile.new(att.decoded)
      document.original_filename = att.filename
      document.content_type = att.mime_type
      mail.user_mail_attachments.create(file: document )
    end
  end

  def sync_mail(msg,message_id, folder_name, folder_id)
    Rails.logger.debug message:"Processing #{message_id}",mailbox:folder_name
    @cnt_mails_processed += 1

    mail_obj = Mail.read_from_string msg
    uid = mail_obj.message_id
    archive_folder_name = account.settings(:sync_options).archive_folder_name

    # TODO: if exist, compare checksums
    if UserMail.exists?(:message_id => uid)
      mail = UserMail.where(message_id: uid).first
      Rails.logger.info "Existing mail #{uid} skipped"
      @cnt_mails_skipped += 1
      @sync_info += "#{folder_name} - #{mail.get_filename} - existing entry \n"
    else
      mail =  mail_from_string(message_id, folder_id, mail_obj)
      mail.mail_account_id = account.id
      #account.user_mails << mail
      #TODO: extract file generation
      if mail.save
        @cnt_mails_new += 1
        @sync_info += "#{folder_name} - #{mail.get_filename} - new entry \n"

        store_source_file(mail_obj,mail)
        store_attachment_files(mail_obj,mail)
      else
        Rails.logger.error("#{mail.errors.full_messages} \n #{mail.inspect}")
        raise mail.errors.full_messages.join(', ')
      end
    end

    if mail_obj.date.present?
      due_date = mail_obj.date + account.settings(:sync_options).delete_after.days
      archive = Date.today > due_date
    else
      archive = true
      Rails.logger.warn("Mail #{mail.subject}, no date set !")
    end

    if archive
      Rails.logger.info("Deleting old mail #{mail.subject.truncate(20)} #{mail.id} received on #{mail.receive_date}, due on #{due_date}")
      #imap.copy(message_id, archive_folder_name)
      send_to_archive(mail_obj)
      imap.store(message_id, "+FLAGS", [:Deleted])
      mail.update_attribute(:archived, true)
      @cnt_mails_archived += 1
      @sync_info += "#{folder_name} - #{mail.get_filename} - archived \n"
    end
  end

  #TODO:parameter for archive mailbox
  def send_to_archive(mail_obj)
    account = self.account
    to = 'mailslave-archive@kaiser-tappe.de'

    msg = ArchiveMailer.send_to_archive_mail(from:account.email,to:to,subject:mail_obj.subject,attachment:mail_obj.to_s)
    msg.delivery_method.settings.merge!({address: account.smtp_server,port:account.smtp_port,user_name:account.login,password:account.password})
    msg.deliver_now!

  end


end