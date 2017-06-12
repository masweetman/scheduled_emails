class CreateScheduledEmails < ActiveRecord::Migration
  def change
    create_table :scheduled_emails do |t|
      t.string :name
      t.string :sender
      t.string :recipient
      t.string :cc
      t.string :bcc
      t.string :reply_to
      t.string :subject
      t.text :message
    end
  end
end