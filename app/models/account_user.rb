class AccountUser < ApplicationRecord
  # Add account roles to this line
  # Do NOT to use any reserved words like `user` or `account`
  ROLES = [:admin, :member]

  enum :relationship_to_child, {
    unspecified: 0,
    dad: 1,
    mom: 2,
    grandparent: 3,
    caregiver: 4,
    other: 5
  }, prefix: :relationship

  include UpdatesSubscriptionQuantity
  include Roles

  belongs_to :account, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: {scope: :account_id}
  validate :owner_must_be_admin, on: :update, if: -> { admin_changed? && account_owner? }

  # Updates the subscription quantity automatically when charge_per_unit is enabled
  updates_subscription_quantity -> { account.per_unit_quantity }

  def account_owner?
    account.owner?(user)
  end

  def owner_must_be_admin
    errors.add :admin, :cannot_be_removed unless admin?
  end
end
