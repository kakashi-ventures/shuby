# frozen_string_literal: true

module ProfileCompleteness
  extend ActiveSupport::Concern

  def profile_completeness_percentage
    fields = completeness_fields
    filled = fields.count { |f| f.present? && f != false }
    (filled.to_f / fields.size * 100).round
  end

  def profile_complete?
    profile_completeness_percentage >= completeness_threshold
  end

  private

  def completeness_threshold
    80
  end
end
