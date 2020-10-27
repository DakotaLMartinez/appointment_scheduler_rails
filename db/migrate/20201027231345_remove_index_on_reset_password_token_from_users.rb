class RemoveIndexOnResetPasswordTokenFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_index "users", name: "index_users_on_reset_password_token"
  end
end
