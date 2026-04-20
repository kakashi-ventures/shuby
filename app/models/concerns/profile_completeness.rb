# frozen_string_literal: true

module ProfileCompleteness
  extend ActiveSupport::Concern

  # Below this percentage we actively nudge the user (e.g. dashboard banner)
  # to fill in the rest. Distinct from COMPLETENESS_THRESHOLD (80%) — crossing
  # NUDGE_THRESHOLD means the profile is barely started, not just imperfect.
  NUDGE_THRESHOLD = 50
  COMPLETENESS_THRESHOLD = 80

  def profile_completeness_percentage
    fields = completeness_fields
    filled = fields.count { |f| f.present? && f != false }
    (filled.to_f / fields.size * 100).round
  end

  def profile_complete?
    profile_completeness_percentage >= completeness_threshold
  end

  def profile_below_nudge_threshold?
    profile_completeness_percentage < NUDGE_THRESHOLD
  end

  private

  def completeness_threshold
    COMPLETENESS_THRESHOLD
  end
end
