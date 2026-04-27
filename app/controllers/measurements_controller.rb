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
    params.expect(measurement: [:measurement_type, :value, :measured_at, :notes, :photo])
  end

  def remove_photo?
    ActiveModel::Type::Boolean.new.cast(params.dig(:measurement, :remove_photo))
  end
end
