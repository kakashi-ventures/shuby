class AddLegalConsentColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :accepted_informed_consent_at, :datetime
    add_column :users, :research_consent_anonymized_at, :datetime
  end
end
