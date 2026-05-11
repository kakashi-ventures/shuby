# frozen_string_literal: true

class DashboardStageContent < ApplicationRecord
  KIND_WEEKLY = "weekly"
  KIND_MONTHLY = "monthly"
  KINDS = [KIND_WEEKLY, KIND_MONTHLY].freeze

  validates :kind, inclusion: {in: KINDS}
  validates :label, :body, presence: true
  validates :min_age_weeks, :max_age_weeks,
    presence: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 8},
    if: :weekly?
  validates :min_age_months, :max_age_months,
    presence: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 36},
    if: :monthly?

  scope :weekly, -> { where(kind: KIND_WEEKLY).order(:min_age_weeks) }
  scope :monthly, -> { where(kind: KIND_MONTHLY).order(:min_age_months) }
  scope :ordered, -> { order(:position) }

  # Resolve the stage card to render on the dashboard hero for a given child.
  # Weekly content covers the first two months (mirrors Timeline::AgeBands).
  # The `weeks.clamp(1, 8)` step absorbs a rounding gap: days ~56-60 yield
  # `questionnaire_age_in_weeks == 9` while `questionnaire_age_in_months == 1`,
  # so without clamping the lookup would fall through to monthly and find
  # nothing (lowest monthly row is Mese 2).
  def self.for_child(child)
    months = child.questionnaire_age_in_months
    weeks = child.questionnaire_age_in_weeks

    if months <= 1 && weeks.present?
      effective_weeks = weeks.clamp(1, 8)
      weekly.where("min_age_weeks <= ? AND max_age_weeks >= ?", effective_weeks, effective_weeks).first
    else
      clamped = [months, 36].min
      monthly.where("min_age_months <= ? AND max_age_months >= ?", clamped, clamped).first
    end
  end

  def weekly?
    kind == KIND_WEEKLY
  end

  def monthly?
    kind == KIND_MONTHLY
  end
end
