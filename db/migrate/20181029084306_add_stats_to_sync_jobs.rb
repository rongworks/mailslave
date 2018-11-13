class AddStatsToSyncJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :sync_jobs, :complete, :boolean
    add_column :sync_jobs, :success, :boolean
    add_column :sync_jobs, :state, :string
  end
end
