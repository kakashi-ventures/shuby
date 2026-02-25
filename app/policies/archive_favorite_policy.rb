# frozen_string_literal: true

# Archive favorites are user-scoped (not account-scoped).
# Any authenticated user can save/unsave published content.
class ArchiveFavoritePolicy < ApplicationPolicy
  def create?
    account_user.present?
  end

  def destroy?
    account_user.present?
  end
end
