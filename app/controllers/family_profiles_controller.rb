# frozen_string_literal: true

class FamilyProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family_profile

  # GET /family_profile/edit
  def edit
    @children = current_account.children.active.ordered.includes(:health_profile)
  end

  # PATCH/PUT /family_profile
  def update
    if @family_profile.update(family_profile_params)
      redirect_to root_path, notice: t(".success")
    else
      @children = current_account.children.active.ordered.includes(:health_profile)
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_family_profile
    @family_profile = current_account.family_profile || current_account.build_family_profile
  end

  def family_profile_params
    params.require(:family_profile).permit(
      :nationality, :country, :mother_tongue, :family_structure,
      :two_parents_type, :has_hereditary_conditions,
      primary_caregivers: [], hereditary_conditions: []
    )
  end
end
