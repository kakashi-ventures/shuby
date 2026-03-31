class UserResource < Madmin::Resource
  menu parent: "Users & Accounts", position: 1

  # Scopes for filtering
  scope :admins, -> { where(admin: true) }

  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :email
  attribute :password, :password, edit: false
  attribute :terms_of_service, :boolean, edit: false
  attribute :time_zone, form: false
  attribute :reset_password_sent_at, form: false
  attribute :remember_created_at, form: false
  attribute :confirmed_at, form: false
  attribute :confirmation_sent_at, form: false
  attribute :unconfirmed_email, form: false
  attribute :accepted_terms_at, form: false
  attribute :accepted_privacy_at, form: false
  attribute :otp_required_for_login, form: false
  attribute :avatar, index: false
  attribute :admin, form: false
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :account_invitations, form: false
  attribute :account_users, form: false
  attribute :accounts, form: false
  attribute :owned_accounts, form: false
  attribute :personal_account, form: false
  attribute :connected_accounts, form: false

  def self.display_name(record)
    record.admin? ? "#{record.name} (Admin)" : record.name
  end

  member_action do |user|
    button_to "Impersonate", madmin_user_impersonate_path(user), class: "btn btn-secondary"

    if user.admin?
      button_to "Rimuovi Admin",
        madmin_user_toggle_admin_path(user),
        class: "btn btn-danger",
        data: {turbo_confirm: "Sei sicuro di voler rimuovere i privilegi admin a #{user.name}?"}
    else
      button_to "Rendi Admin",
        madmin_user_toggle_admin_path(user),
        class: "btn btn-warning",
        data: {turbo_confirm: "Sei sicuro di voler rendere #{user.name} un Admin? Gli admin hanno accesso completo al pannello di amministrazione."}
    end
  end
end
