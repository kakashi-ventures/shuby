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
  include User::Searchable
  include User::Theme

  # Shuby chat conversations
  has_many :shuby_chats, dependent: :destroy

  # Archive favorites
  has_many :archive_favorites, dependent: :destroy
  has_many :favorite_archive_contents, through: :archive_favorites, source: :archive_content

  scope :admins, -> { where(admin: true) }

  # Normalize text fields to strip whitespace
  normalizes :first_name, :last_name, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ") : value }
end
