# frozen_string_literal: true

class Settings::PrivacyController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    Rails.logger.info "=== Privacy Update ==="
    Rails.logger.info "Params: #{user_params.inspect}"
    Rails.logger.info "Before: #{current_user.data_sharing_consent.inspect}"

    if current_user.update(user_params)
      Rails.logger.info "After: #{current_user.data_sharing_consent.inspect}"
      redirect_to settings_privacy_path, notice: t(".updated")
    else
      Rails.logger.info "Errors: #{current_user.errors.full_messages}"
      render :show, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:data_sharing_consent)
  end
end
