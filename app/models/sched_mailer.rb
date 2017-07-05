# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'roadie'

class SchedMailer < ActionMailer::Base
  layout 'mailer'
  helper :application
  helper :issues
  helper :custom_fields
  default from: 'michael.sweetman@ago.org'

  include Redmine::I18n
  include Roadie::Rails::Automatic

  def send_scheduled_email(scheduled_email)
    @scheduled_email = scheduled_email
    mail :to => @scheduled_email.recipient, :subject => @scheduled_email.subject
  end

  def mail(headers={}, &block)
    headers.reverse_merge! 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'X-Auto-Response-Suppress' => 'All',
            'Auto-Submitted' => 'auto-generated',
            'From' => 'michael.sweetman@ago.org',
            'List-Id' => "<#{Setting.mail_from.to_s.gsub('@', '.')}>"

    # Replaces users with their email addresses
    [:to, :cc, :bcc].each do |key|
      if headers[key].present?
        headers[key] = self.class.email_addresses(headers[key])
      end
    end

    if @message_id_object
      headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
    end
    if @references_objects
      headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
    end

    m = if block_given?
      super headers, &block
    else
      super headers do |format|
        format.text
        format.html unless Setting.plain_text_mail?
      end
    end
    set_language_if_valid @initial_language

    m
  end

  def initialize(*args)
    @initial_language = current_language
    set_language_if_valid Setting.default_language
    super
  end

  def self.deliver_mail(mail)
    return false if mail.to.blank? && mail.cc.blank? && mail.bcc.blank?
    begin
      # Log errors when raise_delivery_errors is set to false, Rails does not
      mail.raise_delivery_errors = true
      super
    rescue Exception => e
      if ActionMailer::Base.raise_delivery_errors
        raise e
      else
        Rails.logger.error "Email delivery error: #{e.message}"
      end
    end
  end

  def self.method_missing(method, *args, &block)
    if m = method.to_s.match(%r{^deliver_(.+)$})
      ActiveSupport::Deprecation.warn "Mailer.deliver_#{m[1]}(*args) is deprecated. Use Mailer.#{m[1]}(*args).deliver instead."
      send(m[1], *args).deliver
    else
      super
    end
  end

  # Returns an array of email addresses to notify by
  # replacing users in arg with their notified email addresses
  #
  # Example:
  #   Mailer.email_addresses(users)
  #   => ["foo@example.net", "bar@example.net"]
  def self.email_addresses(arg)
    arr = Array.wrap(arg)
    mails = arr.reject {|a| a.is_a? Principal}
    users = arr - mails
    if users.any?
      mails += EmailAddress.
        where(:user_id => users.map(&:id)).
        where("is_default = ? OR notify = ?", true, true).
        pluck(:address)
    end
    mails
  end

  private

  # Appends a Redmine header field (name is prepended with 'X-Redmine-')
  def redmine_headers(h)
    h.each { |k,v| headers["X-Redmine-#{k}"] = v.to_s }
  end

  def self.token_for(object, rand=true)
    timestamp = object.send(object.respond_to?(:created_on) ? :created_on : :updated_on)
    hash = [
      "redmine",
      "#{object.class.name.demodulize.underscore}-#{object.id}",
      timestamp.strftime("%Y%m%d%H%M%S")
    ]
    if rand
      hash << Redmine::Utils.random_hex(8)
    end
    host = Setting.mail_from.to_s.strip.gsub(%r{^.*@|>}, '')
    host = "#{::Socket.gethostname}.redmine" if host.empty?
    "#{hash.join('.')}@#{host}"
  end

  # Returns a Message-Id for the given object
  def self.message_id_for(object)
    token_for(object, true)
  end

  # Returns a uniq token for a given object referenced by all notifications
  # related to this object
  def self.references_for(object)
    token_for(object, false)
  end

  def message_id(object)
    @message_id_object = object
  end

  def references(object)
    @references_objects ||= []
    @references_objects << object
  end

  def mylogger
    Rails.logger
  end
end
