# frozen_string_literal: true

module User::BetaTester
  extend ActiveSupport::Concern

  included do
    has_many :beta_feedbacks, dependent: :destroy

    scope :beta_testers, -> { where(beta_tester: true) }
  end

  def beta_tester?
    beta_tester == true
  end
end
