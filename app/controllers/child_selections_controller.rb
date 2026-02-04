# frozen_string_literal: true

class ChildSelectionsController < ApplicationController
  before_action :authenticate_user!

  def update
    child = current_account.children.active.find(params[:id])
    select_child(child)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "dashboard-header",
          partial: "shared/dashboard_header/dashboard_header"
        )
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
end
