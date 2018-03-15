class CreateSyncJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :sync_jobs do |t|
      t.references :mail_account, foreign_key: true
      t.datetime :sync_start
      t.datetime :sync_end
      t.integer :new_entries
      t.integer :skipped_entries
      t.integer :processed_entries
      t.text :info

      t.timestamps
    end
  end
end
