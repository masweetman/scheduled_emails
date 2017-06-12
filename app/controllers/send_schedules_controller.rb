class SendSchedulesController < ApplicationController
  unloadable
  
  before_action :require_admin

  def new
    @scheduled_email = ScheduledEmail.find(params[:scheduled_email_id])
    @send_schedule = SendSchedule.new
  end

  def create
    @scheduled_email = ScheduledEmail.find(params[:scheduled_email_id])
    @send_schedule = @scheduled_email.send_schedules.create(send_schedule_params)

    @send_schedule.month_day = params[:send_schedule][:month_day].reject{ |i| i==''}
    @send_schedule.week_day = params[:send_schedule][:week_day].reject{ |i| i==''}
    @send_schedule.month = params[:send_schedule][:month].reject{ |i| i==''}
    @send_schedule.week = params[:send_schedule][:week].reject{ |i| i==''}

    if @send_schedule.save
      redirect_to edit_scheduled_email_path(@scheduled_email)
    else
      render 'new'
    end
  end

  def edit
    @scheduled_email = ScheduledEmail.find(params[:scheduled_email_id])
    @send_schedule = SendSchedule.find(params[:id])
  end

  def update
    @scheduled_email = ScheduledEmail.find(params[:scheduled_email_id])
    @send_schedule = SendSchedule.find(params[:id])

    if @send_schedule.update(send_schedule_params)
      redirect_to edit_scheduled_email_path(@scheduled_email)
    else
      render 'edit'
    end
  end

  def destroy
    @scheduled_email = ScheduledEmail.find(params[:scheduled_email_id])
    @send_schedule = SendSchedule.find(params[:id])
    @send_schedule.destroy
    redirect_to edit_scheduled_email_path(@scheduled_email)
    flash[:notice] = l(:notice_successful_delete)
  end

  private
    def send_schedule_params
      params.require(:send_schedule).permit(:send_at, :recurring, :month_day, :week_day, :month, :week)
    end
end
