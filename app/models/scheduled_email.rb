class ScheduledEmail < ActiveRecord::Base
  has_many :send_schedules, :dependent => :destroy

  def next_send
    dates = []
    send_schedules.each do |schedule|
      dates << schedule.next_send
    end
    return dates.compact.uniq.sort.reject{ |d| d < Date.today }.first
  end

end