class Account < ApplicationRecord
  has_prefix_id :acct

  include Billing
  include Domains
  include Transfer
  include Types

  has_many :children, dependent: :destroy
  has_one :family_profile, dependent: :destroy

  accepts_nested_attributes_for :family_profile
  accepts_nested_attributes_for :children, allow_destroy: true
end
