# frozen_string_literal: true

class Madmin::User::ToggleBetaTestersController < Madmin::ApplicationController
  def create
    user = ::User.find(params[:user_id])
    user.update!(beta_tester: !user.beta_tester?)

    action = user.beta_tester? ? "abilitato come Beta Tester" : "rimosso dai Beta Tester"
    redirect_to main_app.madmin_user_path(user), notice: "#{user.name} #{action}.", status: :see_other
  end
end
