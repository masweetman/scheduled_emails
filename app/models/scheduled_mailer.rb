class ScheduledMailer < ActionMailer::Base
  helper :application

  def send_scheduled_email(scheduled_email)
    @scheduled_email = scheduled_email
    if @scheduled_email.sender.to_s == ""
      from = Setting.mail_from
    else
      from = @scheduled_email.sender
    end
    mail from: from, to: @scheduled_email.recipient, subject: @scheduled_email.subject
  end

end