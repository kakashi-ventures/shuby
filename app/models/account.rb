class Account < ApplicationRecord
  has_prefix_id :acct

  include Billing
  include Domains
  include Transfer
  include Types

  has_many :beta_feedbacks, dependent: :destroy
  has_many :children, dependent: :destroy
  has_many :shuby_chats, dependent: :destroy
  has_one :family_profile, dependent: :destroy

  accepts_nested_attributes_for :family_profile
  accepts_nested_attributes_for :children, allow_destroy: true

  # True when either the family profile isn't complete OR any child's profile
  # is below the nudge threshold. Used by the dashboard profile banner.
  def needs_profile_completion_nudge?
    !family_profile&.profile_complete? ||
      children.any?(&:profile_below_nudge_threshold?)
  end
end
