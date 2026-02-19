# frozen_string_literal: true

class PediatricianQuestionsController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child

  def create
    @question = @child.pediatrician_questions.build(question_params)
    authorize @question

    if @question.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to child_path(@child, tab: "info"), notice: t(".created") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("pediatrician_question_form", partial: "pediatrician_questions/form", locals: {child: @child, question: @question}) }
        format.html { redirect_to child_path(@child, tab: "info"), alert: @question.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @question = @child.pediatrician_questions.find(params[:id])
    authorize @question
    @question.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to child_path(@child, tab: "info"), status: :see_other, notice: t(".destroyed") }
    end
  end

  private

  def question_params
    params.expect(pediatrician_question: [:body])
  end
end
