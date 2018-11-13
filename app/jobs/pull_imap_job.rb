class PullImapJob < Struct.new(:sync_job_id)
  attr_accessor :sync_job, :complete, :successful, :state, :start, :end


  def perform(*args)
    account = self.sync_job.mail_account
    self.state = 'Running'
    update_sync_job
    account.pull_imap
  end

  def enqueue(job)
    self.sync_job = SyncJob.find(self.sync_job_id)
    self.start = Time.now
    self.complete = false
    self.successful = false
    self.state = 'Enqueued'
    update_sync_job
  end

  def success(job)
    self.successful = true
    self.complete = true
    self.state = 'Succeeded'
    self.end = Time.now
    update_sync_job
  end

  #def error(job, exception)
  #  Airbrake.notify(exception)
  #end

  def failure(job)
    self.successful = true
    self.complete = true
    self.state = 'Failed'
    update_sync_job
  end

  def queue_name
    'mail_sync'
  end

  def max_attempts
    2
  end

  def update_sync_job
    updated = self.sync_job.update_attributes(success:self.successful,complete:self.complete,state:self.state,sync_start:self.start,sync_end:self.end)
    raise "Could not update Sync Job" unless updated
    self.sync_job.reschedule if self.complete
  end
end
