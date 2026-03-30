class Madmin::User::ToggleAdminsController < Madmin::ApplicationController
  def create
    user = ::User.find(params[:user_id])
    new_value = !user.admin?

    # Use SQL directly because admin is attr_readonly in the model
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql([
        "UPDATE users SET admin = ?, updated_at = ? WHERE id = ?",
        new_value, Time.current, user.id
      ])
    )

    action = new_value ? "promosso ad Admin" : "rimosso da Admin"
    redirect_to main_app.madmin_user_path(user), notice: "#{user.name} #{action}.", status: :see_other
  end
end
