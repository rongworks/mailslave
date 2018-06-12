class AddArchivedMailsToSyncJob < ActiveRecord::Migration[5.0]
  def change
    add_column :sync_jobs, :archived_entries, :integer
  end
end
