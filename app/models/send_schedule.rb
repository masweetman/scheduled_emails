class SendSchedule < ActiveRecord::Base
  belongs_to :scheduled_email
  serialize :month_day, Array
  serialize :week_day, Array
  serialize :month, Array
  serialize :week, Array

  def monthly
    dates = []
    unless month.empty? || month_day.empty?
      month.each do |m|
        month_day.each do |d|
          begin
            dates << (m + ' ' + d).to_date
          rescue
            nil
          end
        end
      end
      dates << dates.sort.first + 1.year
    end
    return dates.reject{ |d| d < Date.today }
  end

  def weekly
    dates = []
    unless month.empty? || week_day.empty? || week.empty?
      month.each do |m|
        start_date = m.to_date
        end_date = start_date + 1.month - 1
        dates += (start_date..end_date).to_a.select {|d| week_day.map{ |e| e.to_date.wday }.include?(d.wday)}
      end
      dates << dates.sort.first + 1.year
    end
    return dates.reject{ |d| d < Date.today }
  end

  def next_send
    (monthly + weekly).uniq.sort.first
  end

  def day_text
    if month_day.count == 31
      return l(:every_day)
    else
      return month_day.map{ |d| d.to_i.ordinalize }.join(', ')
    end
  end

  def month_text
    if month.count == 12
      return l(:every_month)
    else
      return month.join(', ')
    end
  end

  def week_text
    weeks = []
    week_day.each do |weekday|
      if week.count == 5
        weeks << l(:every) + ' ' + weekday
      elsif week.count > 0
        weeks << week.map{ |w| w.to_i.ordinalize }.join(', ') + ' ' + weekday
      end
    end
    return weeks
  end

end