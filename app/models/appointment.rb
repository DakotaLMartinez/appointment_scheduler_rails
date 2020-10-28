class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  validates :start_time, :end_time, :location, presence: true
  validate :doctor_double_booked, :patient_double_booked, :ends_after_it_starts
  # what does it mean for a double booking to exist. What conditions mean that a doctor or a patient is double booked?
  # if the doctor has any appointment that:
  #   starts in the middle of this appointment (other_appt.start_time < this_appt.start_time && thor ends in the middle of this appointment then it's a double booking on the doctor's part
  # other_start < this_end && this_end < other_end # this means that this appointment ends in the middle of an existing appointment.

  # other_start < this_start && this_start < other_end means that this appointment starts in the middle of an existing appointment
  def doctor_double_booked
    this_start = self.start_time
    this_end = self.end_time
    conflict = doctor.appointments.any? do |appointment|
      other_start = appointment.start_time 
      other_end = appointment.end_time
      other_start < this_end && this_end < other_end || other_start < this_start && this_start < other_end
    end
    if conflict
      errors.add(:doctor, 'has a conflicting appointment')
    end
  end

  def patient_double_booked
    this_start = self.start_time
    this_end = self.end_time
    conflict = patient.appointments.any? do |appointment|
      other_start = appointment.start_time 
      other_end = appointment.end_time
      other_start < this_end && this_end < other_end || other_start < this_start && this_start < other_end
    end
    if conflict
      errors.add(:patient, 'has a conflicting appointment')
    end
  end

  def ends_after_it_starts
    if start_time > end_time
      errors.add(:start_time, 'must be before the end time')
    end
  end

end
