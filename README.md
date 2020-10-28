# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# Doctor, Patient, Appointment
## What is the Many to many relationship and how is it used?
Doctors <=> Patients, we have a view to display all of a doctor's patients and a view to display all of a patient's doctors:
/doctors/:doctor_id/patients
/patients/:patient_id/doctors
## What is the User Submittable attribute on the join model?
Appointments have a start_time, end_time and location.
## What Validations do we need?
Doctor must have a name, phone_number, specializations
Patients must have a name, 
Appointments must have doctor_id, patient_id, start_time, end_time, location
## How do users fit into the application? How are they related to the other models?
If a user is a parent, then how is it related to Doctor, Patient and Appointment,
user has_many :patients, has_many :doctors, through: :patients, user has_many :appointments, through: :patients
if a user was a receptionist, then how is it related to Doctor Patient, and Appointments
everything might belong to a user to make sure we don't see information related to other accounts.

## What are our Nested Routes? (We need a nested new route and either a nested index or nested show route)
/patients/:patient_id/doctors => all of that patient's doctors
/patients/:patient_id/appointments => all appointments made with that patient (the one who is identified by `params[:patient_id]`)
/patients/:patient_id/appointments/new => a new appointment form with the patient pre-selected
## Do we have Non Nested Versions of those nested routes?
/appointments => all appointments created by this user.
/appointments/new => a new appointment form where user must select the patient.
## What Scope Method(s) do we have and how are they used? (class methods that return an ActiveRecord::Relation)
Appointment.past => appointments that have ended already.
Appointment.upcoming => appointments that haven't started yet.
in your appointments#index action, you could accept a query parameter for time and check whether it says "past" or "upcoming" and add that scope to the results as appropriate. 
/appointments?time=past => We'll have the .past scope method added to our results
/appointments?time=upcoming => We'll have the .upcoming scope method added to our results 
## What does the schema for our app look like?

```rb
# table migration for: users 
# t.string :email
# t.string :phone_number


class User 
  # relationships
  has_many :patients
  has_many :appointments, through: :patients
  
	# validations 
  validates :email, :phone_number, presence: true, uniqueness: true
  
	# scope_methods (if any)


end
# table migration for: doctors 
# t.string :name
# t.string :phone_number
# t.string :specializations

class Doctor 
       # relationships
  has_many :appointments
  has_many :patients, through: :appointments

	# validations 
  validates :name, :phone_number, :specializations, presence: true
	# user submittable attributes (if this is a join model)
  
	# scope_methods (if any)


end

# table migration for: patients 
# t.string :name
# t.references :user

class Patient 
       # relationships
  belongs_to :user
  has_many :appointments
  has_many :doctors, through: :appointments

	# validations 
  validates :name, presence: true

end

# table migration for: appointments 
# t.references :doctor
# t.references :patient 
# t.datetime :start_time 
# t.datetime :end_time 
# t.string :location

class Appointment 
       # relationships
  belongs_to :doctor
  belongs_to :patient
  delegate :user, to: :patient

	# validations 
  validates :doctor_id, :patient_id, :start_time, :end_time, :location, presence: true
	# user submittable attributes (if this is a join model) start_time, end_time and location
  
	# scope_methods (if any)
  # Appointment.past => appointments that have ended already.
  # Appointment.upcoming => appointments that haven't started yet.

end

```
