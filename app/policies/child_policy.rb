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
    account_user.present?
  end

  def update?
    account_user.present?
  end

  def destroy?
    account_user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
