# frozen_string_literal: true

module ChildScoped
  extend ActiveSupport::Concern

  private

  def set_child
    @child = policy_scope(Child).find(params[:child_id])
    authorize @child, :show?
  end
end
