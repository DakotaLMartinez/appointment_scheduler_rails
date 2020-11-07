class Doctor::AppointmentsController < ApplicationController
  before_action :authenticate_doctor!
  def index 
    @appointments = current_doctor.appointments
  end
end
