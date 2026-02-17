# frozen_string_literal: true

class ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child, only: [:show, :edit, :update, :destroy]

  # GET /children
  def index
    @children = policy_scope(Child).active.ordered
    authorize Child
  end

  # GET /children/:id
  def show
    @tab = params[:tab] || "info"
    if @tab == "misurazioni"
      @measurements_by_type = Measurement.measurement_types.keys.map do |type|
        [type, @child.latest_measurement(type)]
      end
    end
  end

  # GET /children/new
  def new
    @child = Child.new
    authorize @child
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
    redirect_to children_url, status: :see_other, notice: t(".destroyed")
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
        :id, :birth_weight_grams, :hearing_screening_result, :vision_screening_result,
        :current_feeding_type, :average_sleep_hours
      ]
    ])
  end
end
