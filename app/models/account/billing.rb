module Account::Billing
  extend ActiveSupport::Concern

  included do
    pay_customer

    define_method :pay_should_sync_customer? do
      saved_change_to_owner_id? || saved_change_to_billing_email?
    end
  end

  # Email address used for Pay customers and receipts
  # Defaults to billing_email if defined, otherwise uses the account owner's email
  def email
    billing_email? ? billing_email : owner.email
  end

  # Returns true if this account has an active premium subscription.
  # Centralised check — use this instead of querying payment_processor directly.
  def premium?
    payment_processor&.subscribed? || false
  end

  # Maximum number of children allowed for this account's plan tier.
  def children_limit
    premium? ? 3 : 1
  end

  # Used for per-unit subscriptions on create and update
  # Returns the quantity that should be on the subscription
  def per_unit_quantity
    account_users_count
  end
end
