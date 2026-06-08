# frozen_string_literal: true

# Settings → "Report PDF": lets a parent choose which sections are included in
# the PDFs they share with the pediatrician — the growth report (child Info
# tab) and the per-stage report (Tappe tab). Preferences persist on
# User#preferences and are read back by the report aggregators at generation
# time. Free for all users — a privacy control (PRD §3.8.2), not a premium perk.
class Settings::PdfController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    if current_user.update(pdf_params)
      respond_to do |format|
        # Toggles auto-submit via Turbo. Answer 204 so Turbo does nothing —
        # no redirect, no full-body swap, no page-transition replay. The
        # checkbox already reflects the click; we only needed to persist it.
        format.turbo_stream { head :no_content }
        format.html { redirect_to settings_pdf_path, notice: t(".updated") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_content }
        format.html do
          redirect_to settings_pdf_path,
            alert: current_user.errors.full_messages.to_sentence.presence || t(".invalid"),
            status: :see_other
        end
        format.json { render json: current_user.errors, status: :unprocessable_content }
      end
    end
  end

  private

  def pdf_params
    params.require(:user).permit(*User::ReportPreferences::BOOLEAN_KEYS)
  end
end
