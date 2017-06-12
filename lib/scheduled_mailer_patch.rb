require 'mailer'

module ScheduledMailerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do 
      unloadable   
    end  
  end

  module InstanceMethods

  def send_scheduled_email(scheduled_email)
    @scheduled_email = scheduled_email
    mail :to => @scheduled_email.recipient, :subject => @scheduled_email.subject
  end

  end
end

Mailer.send(:include, ScheduledMailerPatch)