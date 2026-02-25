class User < ApplicationRecord
  has_prefix_id :user

  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::ChatRateLimit
  include User::DataSharingConsent
  include User::Mentions
  include User::Notifiable
  include User::Onboarding
  include User::Searchable
  include User::Theme

  has_one_attached :avatar
  has_person_name

  # Shuby chat conversations
  has_many :shuby_chats, dependent: :destroy

  # Archive favorites
  has_many :archive_favorites, dependent: :destroy
  has_many :favorite_archive_contents, through: :archive_favorites, source: :archive_content

  validates :avatar, resizable_image: true
  validates :name, presence: true

  # Normalize text fields to strip whitespace
  normalizes :first_name, :last_name, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ") : value }
end
