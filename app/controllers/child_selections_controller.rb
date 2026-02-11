# frozen_string_literal: true

class ChildSelectionsController < ApplicationController
  before_action :authenticate_user!

  def update
    child = current_account.children.active.find(params[:id])
    select_child(child)

    redirect_back(fallback_location: root_path)
  end
end
