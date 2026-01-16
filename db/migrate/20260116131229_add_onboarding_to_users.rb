class AddOnboardingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :onboarding_completed_at, :datetime
    add_column :users, :onboarding_step, :integer, default: 0
    add_index :users, :onboarding_completed_at
  end
end
