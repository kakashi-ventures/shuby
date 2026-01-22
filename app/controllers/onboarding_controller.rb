# frozen_string_literal: true

class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_completed
  before_action :set_account

  layout "onboarding"

  # Step 1: Family Profile
  def family_profile
    @family_profile = @account.family_profile || @account.build_family_profile
  end

  def update_family_profile
    @family_profile = @account.family_profile || @account.build_family_profile

    if @family_profile.update(family_profile_params)
      current_user.update!(onboarding_step: :children)
      redirect_to onboarding_children_path
    else
      render :family_profile, status: :unprocessable_content
    end
  end

  # Step 2: Children
  def children
    @family_profile = @account.family_profile
    if @family_profile.nil?
      redirect_to onboarding_family_profile_path
      return
    end
    ensure_children_count
    @children = @account.children.includes(:health_profile)
  end

  def update_children
    validate_children_count

    if @validation_error
      @family_profile = @account.family_profile
      @children = @account.children.includes(:health_profile)
      flash.now[:alert] = @validation_error
      render :children, status: :unprocessable_content
      return
    end

    if @account.update(children_params)
      current_user.update!(onboarding_step: :health_history)
      redirect_to onboarding_health_history_path
    else
      @family_profile = @account.family_profile
      @children = @account.children.includes(:health_profile)
      render :children, status: :unprocessable_content
    end
  end

  # Step 3: Health History
  def health_history
    @family_profile = @account.family_profile
    redirect_to onboarding_family_profile_path if @family_profile.nil?
  end

  def update_health_history
    @family_profile = @account.family_profile

    if @family_profile.nil?
      redirect_to onboarding_family_profile_path
      return
    end

    if @family_profile.update(health_history_params)
      current_user.complete_onboarding!
      redirect_to onboarding_complete_path
    else
      render :health_history, status: :unprocessable_content
    end
  end

  # Step 4: Completion
  def complete
    # Show thank you message and transparency note
  end

  def finish
    redirect_to root_path
  end

  private

  def redirect_if_completed
    redirect_to root_path if current_user.onboarding_completed?
  end

  def set_account
    @account = current_account
  end

  def ensure_children_count
    target_count = @account.family_profile&.number_of_children || 1
    current_count = @account.children.count

    (target_count - current_count).times do
      child = @account.children.build
      child.build_health_profile
    end
  end

  def family_profile_params
    params.require(:family_profile).permit(
      :country, :nationality, :mother_tongue,
      :family_structure, :two_parents_type,
      :number_of_children, :languages_spoken_at_home
    )
  end

  def children_params
    params.require(:account).permit(
      children_attributes: [
        :id, :name, :nickname, :birth_date, :sex,
        :gestational_weeks, :gestational_days, :_destroy,
        health_profile_attributes: [
          :id, :is_multiple_birth, :gestational_age_category,
          :birth_weight_grams, :pregnancy_type,
          :hospitalized_after_birth,
          :birth_weight_under_1500, :required_oxygen_ventilation,
          :hearing_screening_result, :vision_screening_result,
          :current_feeding_type, :started_complementary_feeding,
          :complementary_feeding_start_date, :main_foods_introduced,
          :feeding_difficulties, :average_sleep_hours,
          :floor_play_minutes_per_day,
          {birth_complications: [], sleep_quality_issues: [], scheduled_followups: []}
        ]
      ]
    )
  end

  def health_history_params
    params.require(:family_profile).permit(
      :has_hereditary_conditions,
      {primary_caregivers: [], hereditary_conditions: []}
    )
  end

  def validate_children_count
    expected_count = @account.family_profile&.number_of_children || 1

    # Count valid children in the submitted params
    children_attributes = children_params.dig(:children_attributes)
    return unless children_attributes

    # Count children that have either name or nickname filled
    valid_children_count = children_attributes.values.count do |attrs|
      next if attrs[:_destroy] == "1" # Skip destroyed records
      attrs[:name].present? || attrs[:nickname].present?
    end

    if valid_children_count < expected_count
      @validation_error = I18n.t(
        "onboarding.children.errors.incomplete_profiles",
        expected: expected_count,
        actual: valid_children_count
      )
    elsif valid_children_count > expected_count
      @validation_error = I18n.t(
        "onboarding.children.errors.too_many_profiles",
        expected: expected_count,
        actual: valid_children_count
      )
    end
  end
end
