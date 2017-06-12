namespace :redmine do
  task :send_scheduled_emails => :environment do
    ScheduledEmail.all.each do |scheduled_email|
      if scheduled_email.next_send == Date.today
        Mailer.send_scheduled_email(scheduled_email).deliver
      end
  end
end