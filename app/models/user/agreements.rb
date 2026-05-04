module User::Agreements
  extend ActiveSupport::Concern

  included do
    # Combined Terms + Privacy acceptance checkbox at signup
    attribute :terms_of_service
    validates :terms_of_service, presence: true, acceptance: true, on: [:create, :invitation_accepted]

    # Informed Consent — required precondition to use the platform
    # (GDPR art. 9: explicit consent for processing minor's health data)
    attribute :informed_consent
    validates :informed_consent, presence: true, acceptance: true, on: [:create, :invitation_accepted]

    after_validation :accept_terms, on: [:create, :invitation_accepted]
    after_validation :accept_privacy, on: [:create, :invitation_accepted]
    after_validation :accept_informed_consent, on: [:create, :invitation_accepted]
  end

  def accept_terms
    self.accepted_terms_at = Time.zone.now
  end

  def accept_privacy
    self.accepted_privacy_at = Time.zone.now
  end

  def accept_informed_consent
    self.accepted_informed_consent_at = Time.zone.now
  end

  # Optional anonymized research consent — revocable any time
  # (GDPR art. 7(3): revocation must be as easy as giving consent).
  # The boolean is mapped to a timestamp on the column so we keep proof
  # of when consent was given.
  def research_consent_anonymized=(value)
    self.research_consent_anonymized_at = ActiveModel::Type::Boolean.new.cast(value) ? Time.zone.now : nil
  end

  def research_consent_anonymized
    research_consent_anonymized_at.present?
  end
end
