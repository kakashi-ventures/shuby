# frozen_string_literal: true

class QuestionnaireSessionPolicy < ApplicationPolicy
  def index?
    account_user.present?
  end

  def show?
    account_user.present? && owns_child?
  end

  def create?
    account_user.present? && owns_child?
  end

  def update?
    account_user.present? && owns_child?
  end

  def continue?
    show?
  end

  def overlay_frame?
    show?
  end

  def answer?
    update?
  end

  def complete?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:child).where(children: {account_id: account_user.account_id})
    end
  end

  private

  def owns_child?
    record.child.account_id == account_user.account_id
  end
end
