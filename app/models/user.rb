class User < ApplicationRecord
  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::BetaTester
  include User::ChatRateLimit
  include User::DataSharingConsent
  include User::MeasurementUnit
  include User::Mentions
  include User::Notifiable
  include User::Onboarding
  include User::Profile
  include User::ReportPreferences
  include User::Searchable
  include User::Theme

  # Shuby chat conversations
  has_many :shuby_chats, dependent: :destroy

  # Archive favorites
  has_many :archive_favorites, dependent: :destroy
  has_many :favorite_archive_contents, through: :archive_favorites, source: :archive_content

  scope :admins, -> { where(admin: true) }

  # Normalize text fields: strip whitespace and collapse blank to nil so that a
  # form re-submitting an empty field over a NULL value is not a dirty change.
  # (A phantom NULL -> "" change used to fire sync_personal_account_name and mint
  # a stray personal account — see app/models/user/accounts.rb.)
  normalizes :first_name, :last_name, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ").presence : value }
end
