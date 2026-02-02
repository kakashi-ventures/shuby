# frozen_string_literal: true

class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_completed

  layout "onboarding"

  def show
    @child = current_account.children.first || current_account.children.build
    @family_profile = current_account.family_profile || current_account.build_family_profile
    @account_user = current_account.account_users.find_by(user: current_user)
  end

  def create
    @child = current_account.children.first || current_account.children.build
    @family_profile = current_account.family_profile || current_account.build_family_profile
    @account_user = current_account.account_users.find_by(user: current_user)

    @child.assign_attributes(child_params)
    @family_profile.assign_attributes(family_profile_params)
    @family_profile.country ||= "Italia"
    @family_profile.number_of_children = 1
    @account_user.assign_attributes(account_user_params)
    current_user.assign_attributes(user_params)

    if @child.valid? && @family_profile.valid? && @account_user.valid?
      @child.save!
      @family_profile.save!
      @account_user.save!
      current_user.save!
      current_user.complete_onboarding!
      redirect_to root_path, notice: t("onboarding.success")
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def redirect_if_completed
    redirect_to root_path if current_user.onboarding_completed?
  end

  def child_params
    params.fetch(:child, {}).permit(:name, :birth_date, :sex)
  end

  def family_profile_params
    params.fetch(:family_profile, {}).permit(:languages_spoken_at_home)
  end

  def account_user_params
    params.fetch(:account_user, {}).permit(:relationship_to_child)
  end

  def user_params
    params.fetch(:user, {}).permit(:data_sharing_consent)
  end
end
