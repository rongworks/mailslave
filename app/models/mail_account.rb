require 'mail'
require 'net/imap'

class MailAccount < ApplicationRecord

  crypt_keeper :login, :password , encryptor: :aes_new, key: 'gotMailSlaveToEncrypt', salt: 'salt'

  belongs_to :user
  has_many :user_mails, :inverse_of => :mail_account
  has_many :mailbox_folders, :dependent => :destroy
  has_one :sync_job

  has_settings do |setting|
    setting.key :sync_options, defaults: {
      interval: 100800, # interval for retrieving TODO: implement
      only_seen: true, # only seen messages get archived
      only_older_than: 0, # only archive messages older than X days
      delete_after: 30, # delete messages that are older than x days
      exclude_folders: 'INBOX.Junk,INBOX.Spam',
      archive_folder_name: 'INBOX.mailslave_archive'
    }
  end

  def pull_imap
    search_query = ['UNFLAGGED']
    search_query << 'SEEN' if settings(:sync_options).only_seen
    if settings(:sync_options).only_older_than > 0
      search_query << "BEFORE"
      search_query << (Date.today - settings(:sync_options).only_older_than).strftime('%d-%b-%Y')
    end
    mail_sync = MailSync.new(self)
    mail_sync.sync(exclude_folders, search_query)
    mail_sync.disconnect
  end

  def find_or_create_folder(folder)
    folder_active = settings(:sync_options).exclude_folders.include?(folder)
    acc_folder = mailbox_folders.find_by(name: folder) || mailbox_folders.create(name: folder, sync_active: folder_active)
  end

  def exclude_folders
    return settings(:sync_options).exclude_folders.split(",").map(&:strip) << settings(:sync_options).archive_folder_name
  end

end
