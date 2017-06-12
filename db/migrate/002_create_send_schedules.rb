class CreateSendSchedules < ActiveRecord::Migration
  def change
    create_table :send_schedules do |t|
      t.text :month_day
      t.text :week_day
      t.text :month
      t.text :week
      t.references :scheduled_email, foreign_key: true
    end
  end
end