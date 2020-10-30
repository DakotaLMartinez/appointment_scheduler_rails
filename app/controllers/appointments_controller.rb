class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  def index 
    @appointments = current_user.appointments
  end

  def show 

  end 

  def new 
    @appointment = Appointment.new
  end

  def create 
    @appointment = Appointment.new(appointment_params)
    if @appointment.save 
      redirect_to appointment_path(@appointment)
    else 
      render :new
    end
  end

  def edit 
    
  end 

  def update 
    if @appointment.update(appointment_params)
      redirect_to appointment_path(@appointment)
    else
      render :edit
    end
  end 

  def destroy 
    @appointment.destroy 
    redirect_to appointments_path
  end

  private 

  def set_appointment 
    @appointment = current_user.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:location, :start_time, :end_time, :doctor_id, :patient_id)
  end
end
