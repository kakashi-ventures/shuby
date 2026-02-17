# frozen_string_literal: true

class MeasurementPolicy < ApplicationPolicy
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

  def destroy?
    account_user.present? && owns_child?
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
