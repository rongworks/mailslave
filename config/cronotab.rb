# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
 class TestJob
   def perform
     puts 'Crono is running!'
   end
 end

 Crono.perform(TestJob).every 1.days, at: '00:30'
#
Crono.perform(PullImapJob).every 1.days, at: '22:00'
