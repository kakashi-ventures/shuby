module User::Accounts
  extend ActiveSupport::Concern

  included do
    has_many :account_invitations, dependent: :nullify, foreign_key: :invited_by_id
    has_many :account_users, dependent: :destroy
    has_many :accounts, through: :account_users
    has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
    has_one :personal_account, -> { where(personal: true) }, class_name: "Account", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

    after_create :create_default_account
    after_update :sync_personal_account_name, if: -> { Jumpstart.config.personal_accounts? }

    accepts_nested_attributes_for :owned_accounts, reject_if: :all_blank
  end

  def create_default_account
    if (account = accounts.where(personal: Jumpstart.config.personal_accounts?).first)
      return account
    end

    owned_accounts.create!(name: name, personal: Jumpstart.config.personal_accounts?)
  end

  def sync_personal_account_name
    return unless first_name_previously_changed? || last_name_previously_changed?

    # Shuby divergence from upstream Jumpstart: only sync an EXISTING personal
    # account's name — never create one here. Legacy users registered in team
    # mode own a personal:false account and have no personal account; the
    # upstream `create_default_account` branch minted an empty personal account
    # on any name change, which fallback_account then preferred, hiding their
    # child. See docs/UPSTREAM-ISSUES.md.
    personal_account&.update(name: name)
  end
end
