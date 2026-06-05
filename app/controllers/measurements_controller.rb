# frozen_string_literal: true

class MeasurementsController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]

  def index
    authorize Measurement
    redirect_to child_path(@child, tab: "measurements")
  end

  def show
    @same_type_measurements = @child.measurements
      .by_type(@measurement.measurement_type)
      .where.not(id: @measurement.id)
      .ordered
  end

  def new
    @measurement = @child.measurements.build(
      measurement_type: params[:type] || :weight,
      measured_at: Time.current
    )
    authorize @measurement
  end

  def create
    @measurement = @child.measurements.build(measurement_params)
    authorize @measurement

    if @measurement.save
      # Saving a measurement is a genuine "win" moment — flag it so the layout
      # renders native_review_tag once on the redirect target (iOS App Store
      # rating prompt). Boolean value, so it is ignored by the toast renderer
      # (flash_helper#toasts only picks Hash-valued entries).
      flash[:request_app_review] = true
      redirect_to child_measurement_path(@child, @measurement), notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    @measurement.photo.purge_later if remove_photo?
    if @measurement.update(measurement_params)
      redirect_to child_measurement_path(@child, @measurement), notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @measurement.destroy
    redirect_to child_path(@child, tab: "measurements"), status: :see_other, notice: t(".destroyed")
  end

  private

  def set_measurement
    @measurement = @child.measurements.find(params[:id])
    authorize @measurement
  end

  def measurement_params
    attrs = params.expect(measurement: [:measurement_type, :value, :measured_at, :notes, :photo])
    normalize_weight_value!(attrs)
    attrs
  end

  # Body weight is entered in kg but stored in integer grams (DEC-022).
  # Accept "," or "." as the decimal separator. For partial updates that
  # omit measurement_type, fall back to the persisted record's type.
  def normalize_weight_value!(attrs)
    return unless attrs[:value].present?
    type = attrs[:measurement_type].presence || @measurement&.measurement_type
    return unless type == "weight"
    attrs[:value] = (attrs[:value].to_s.tr(",", ".").to_f * 1000).round
  end

  def remove_photo?
    ActiveModel::Type::Boolean.new.cast(params.dig(:measurement, :remove_photo))
  end
end
