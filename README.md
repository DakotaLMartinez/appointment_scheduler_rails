# Appointment Scheduler Rails

Youtube playlist of build: https://www.youtube.com/playlist?list=PLi0yUl9brD2Oktjm4yytMjVN8FCTEUHuQ

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
# Day 1:

Build out Authentication, Models, schema, associations & validations.

# Day 2:

- Build out our index views for all resources
- Add forms for creating and editing existing resources
- Display error messages for failed validations

# Day 3:

- Build nested routes
- Add scope methods and user interface for viewing their return values.

Oauth cheatsheet:

## Dependencies (Gems/packages)
omniauth
omniauth-google-oauth2
dotenv-rails
## Configuration (environment variables/other stuff in config folder)
config/initializers/devise.rb
```
config.omniauth :google_oauth2, ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET']
``` 
.env
```
GOOGLE_OAUTH_CLIENT_ID='your_id_goes_here'
GOOGLE_OAUTH_CLIENT_SECRET='your_secret_here'
```
add the .env file to the .gitignore file.
Also, we need to go create the application on the google developer platform and get the credentials from there. (As well as specify the authorized redirect URI to be http://localhost:3000/users/auth/google_oauth2/callback)
We had to configure the consent screen on the console. This required us to set the domain. We used this domain: lvh.me/ (an alias for localhost). After we'd configured the consent screen we were able to follow the instructions in the medium article below. The credentials we create will be stored in a .env file, though, not inside of development.rb. And, .env will be gitignored.
Resources:
https://ktor.io/docs/guides-oauth.html
https://medium.com/@adamlangsner/google-oauth-rails-5-using-devise-and-omniauth-1b7fa5f72c8e

## Database
add columns to user table for full_name, uid, email and avatar_url
## Models
add devise: :omniauthable, omniauth_providers: [:google_oauth_2]
```rb
  def self.from_google(uid:, email:, full_name:, avatar_url:)
    user= User.find_or_create_by(email: email) do |u|
      u.uid = uid
      u.full_name = full_name
      u.avatar_url = avatar_url
      u.password = SecureRandom.hex
    end
    user.update(uid: uid, full_name: full_name, avatar_url: avatar_url)
    byebug
  end
  ```
## Views
add link to sign in with google (in our case Devise did that for us, but if we wanted to add a custom image we could use a syntax like this: https://stackoverflow.com/questions/43280001/rails-image-as-a-link/48630860#48630860)
```
<%= link_to(user_google_oauth2_omniauth_authorize_path) do %>
  <%= image_tag(my.image, class: 'product-image__img') if product.image.attached? %>
<% end %>
```
## Controllers
create a Users::OmniauthCallbacksController file in app/controllers/users/omniauth_callbacks_controller.rb
```rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.from_google(from_google_params)
    
    if user.present?
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end
  end

  protected

  def after_omniauth_failure_path_for(_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  private

  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      email: auth.info.email,
      full_name: auth.info.name,
      avatar_url: auth.info.image
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
```
## Routes
```rb
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```
