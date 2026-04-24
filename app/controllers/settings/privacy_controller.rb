# frozen_string_literal: true

class Settings::PrivacyController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    if current_user.update(user_params)
      respond_to do |format|
        format.html { redirect_to settings_privacy_path, notice: t(".updated") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_content }
        format.json { render json: current_user.errors, status: :unprocessable_content }
      end
    end
  end

  def export
    json = GdprDataExportService.new(current_user).call
    send_data json,
      filename: "shuby-dati-#{current_user.name.parameterize}-#{Date.current}.json",
      type: "application/json"
  end

  private

  def user_params
    params.require(:user).permit(:data_sharing_consent, :measurement_unit)
  end
end
