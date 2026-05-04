# frozen_string_literal: true

class Settings::PrivacyController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to settings_path(tab: "configuration"), status: :moved_permanently
  end

  def update
    if current_user.update(user_params)
      respond_to do |format|
        format.html { redirect_to settings_privacy_path, notice: t(".updated") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to settings_path(tab: "configuration"),
            alert: current_user.errors.full_messages.to_sentence.presence || t(".invalid"),
            status: :see_other
        end
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
    params.require(:user).permit(
      :data_sharing_consent,
      :research_consent_anonymized,
      :measurement_unit,
      :push_notifications_enabled,
      :email_newsletter_enabled,
      :stage_reminders_enabled
    )
  end
end
