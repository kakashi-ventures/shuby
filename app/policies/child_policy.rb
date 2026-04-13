# frozen_string_literal: true

class ChildPolicy < ApplicationPolicy
  # All account members can access children shared within the account

  def index?
    account_user.present?
  end

  def show?
    account_user.present?
  end

  def create?
    account_user.present? && under_children_limit?
  end

  def at_children_limit?
    account_user.present? && !under_children_limit?
  end

  def update?
    account_user.present?
  end

  def destroy?
    account_user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account_id: account_user.account_id)
    end
  end

  private

  def under_children_limit?
    account = account_user.account
    account.children.active.count < account.children_limit
  end
end
