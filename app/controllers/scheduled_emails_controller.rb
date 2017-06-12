class ScheduledEmailsController < ApplicationController
  unloadable

  def index
    @scheduled_emails = ScheduledEmail.all
  end

  def new
    @scheduled_email = ScheduledEmail.new
  end

  def create
    @scheduled_email = ScheduledEmail.new(scheduled_email_params)
    if @scheduled_email.save
      redirect_to edit_scheduled_email_path(@scheduled_email)
    else
      render 'new'
    end
  end

  def edit
    @scheduled_email = ScheduledEmail.find(params[:id])
  end

  def update
    @scheduled_email = ScheduledEmail.find(params[:id])
    if @scheduled_email.update(scheduled_email_params)
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @scheduled_email = ScheduledEmail.find(params[:id])
    @scheduled_email.destroy
    redirect_to action: 'index'
    flash[:notice] = l(:notice_successful_delete)
  end
  
  private
    def scheduled_email_params
      params.require(:scheduled_email).permit(:name, :sender, :recipient, :cc, :bcc, :reply_to, :subject, :message)
    end
end