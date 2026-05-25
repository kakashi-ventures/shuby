# frozen_string_literal: true

class ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child, only: [:show, :edit, :update, :destroy]

  # GET /children/:id
  def show
    @tab = params[:tab] || "info"
    case @tab
    when "info"
      @last_report_at = @child.measurements.maximum(:updated_at)
    when "measurements"
      @measurements_by_type = Measurement.measurement_types.keys.map do |type|
        [type, @child.latest_measurement(type)]
      end
      @child.measurements.load # Preload for growth chart rendering
    when "milestones"
      @milestones_data = ChildMilestonesLoader.new(@child).call
    end
  end

  # GET /children/new
  def new
    @child = Child.new
    authorize @child
  rescue Pundit::NotAuthorizedError
    @at_children_limit = true
    render :new
  end

  # GET /children/:id/edit
  def edit
    @child.build_health_profile unless @child.health_profile
  end

  # POST /children
  def create
    @child = current_account.children.new(child_params)
    authorize @child

    if @child.save
      redirect_to @child, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  rescue Pundit::NotAuthorizedError
    redirect_to today_path, alert: t("premium.children.limit_title")
  end

  # PATCH/PUT /children/:id
  def update
    if @child.update(child_params)
      redirect_to @child, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /children/:id
  def destroy
    @child.update!(active: false)
    redirect_to today_path, status: :see_other, notice: t(".destroyed")
  end

  private

  def set_child
    @child = policy_scope(Child).find(params[:id])
    authorize @child
  end

  def child_params
    params.expect(child: [
      :name, :birth_date, :sex, :gestational_weeks, :gestational_days, :notes, :avatar,
      health_profile_attributes: [
        :id, :birth_weight_grams, :birth_height_cm, :hearing_screening_result, :vision_screening_result,
        :current_feeding_type, :average_sleep_hours
      ]
    ])
  end
end
