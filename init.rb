Redmine::Plugin.register :scheduled_emails do

	  name 'Scheduled Emails plugin'
	    author 'Mike Sweetman'
	      description 'Allows admins to schedule emails.'
	        version '0.0.1'
		  url 'https://github.com/masweetman/scheduled_emails'
		    author_url 'https://github.com/masweetman'

			menu :admin_menu, :scheduled_emails, {:controller => 'scheduled_emails', :action => 'index'}, :if => Proc.new { User.current.admin? }, :caption => :label_scheduled_email_plural, :html => {:class => 'icon', :style => 'background-image: url(../images/email.png);'}

end
