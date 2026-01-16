class User < ApplicationRecord
  has_prefix_id :user

  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::Mentions
  include User::Notifiable
  include User::Onboarding
  include User::Searchable
  include User::Theme

  has_one_attached :avatar
  has_person_name

  # Shuby chat conversations
  has_many :shuby_chats, dependent: :destroy

  validates :avatar, resizable_image: true
  validates :name, presence: true
end
