# Agreements track user acceptance of legal documents (Terms, Privacy, Informed
# Consent). Bumping `updated:` triggers a forced re-acceptance flow on next
# request via Users::AgreementUpdates.

Agreement = Data.define(:id, :title, :column, :updated, :prompt_when_updated) do
  def accepted_by?(user)
    accepted_at = user.public_send(column)
    accepted_at.present? && accepted_at >= updated
  end

  def not_accepted_by?(user)
    !accepted_by?(user)
  end

  def to_param
    id
  end

  def to_partial_path
    "agreements/#{id}"
  end
end

# Updated timestamp = first deployment of full legal text from the lawyer.
# Bump this whenever the partial content changes so users get re-prompted.
LEGAL_DOCS_UPDATED_AT = Time.parse("2026-05-04 00:00:00").freeze

Rails.application.config.agreements = [
  Agreement.new(
    id: :terms_of_service,
    title: "Termini e Condizioni",
    column: :accepted_terms_at,
    updated: LEGAL_DOCS_UPDATED_AT,
    prompt_when_updated: true
  ),
  Agreement.new(
    id: :privacy_policy,
    title: "Informativa Privacy",
    column: :accepted_privacy_at,
    updated: LEGAL_DOCS_UPDATED_AT,
    prompt_when_updated: true
  ),
  Agreement.new(
    id: :informed_consent,
    title: "Modulo di Consenso Informato",
    column: :accepted_informed_consent_at,
    updated: LEGAL_DOCS_UPDATED_AT,
    prompt_when_updated: true
  )
]
