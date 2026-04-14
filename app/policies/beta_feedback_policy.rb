# frozen_string_literal: true

class BetaFeedbackPolicy < ApplicationPolicy
  def create?
    account_user.present? && account_user.user.beta_tester?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account_id: account_user.account_id)
    end
  end
end
