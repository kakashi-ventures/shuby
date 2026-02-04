# frozen_string_literal: true

module ChildSelection
  extend ActiveSupport::Concern

  included do |base|
    if base < ActionController::Metal
      before_action :set_current_child
      helper_method :current_child
    end
  end

  def current_child
    @current_child ||= find_current_child
  end

  def select_child(child)
    cookies.encrypted[:selected_child_id] = {
      value: child.id,
      expires: 1.year.from_now
    }
    @current_child = child
  end

  private

  def set_current_child
    @current_child = find_current_child
  end

  def find_current_child
    return nil unless user_signed_in? && current_account.present?

    if cookies.encrypted[:selected_child_id].present?
      child = current_account.children.active.find_by(id: cookies.encrypted[:selected_child_id])
      return child if child.present?
    end

    current_account.children.active.ordered.first
  end
end
