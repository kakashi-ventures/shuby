# frozen_string_literal: true

require "test_helper"

class DailyMilestoneServiceTest < ActiveSupport::TestCase
  setup do
    @sophia = children(:sophia) # ~2 months old
    @date = Date.current
  end

  test "returns finish_previous state when past in-progress session exists" do
    # Sophia has past in-progress sessions (month 0 and month 1)
    result = DailyMilestoneService.call(@sophia, date: @date)

    assert_equal :finish_previous, result[:state]
    assert_not_nil result[:session]
    assert result[:session].in_progress?
    assert_not_nil result[:milestone]
  end

  test "finish_previous session is from a past age band" do
    result = DailyMilestoneService.call(@sophia, date: @date)

    assert_equal :finish_previous, result[:state]
    current_age = @sophia.questionnaire_age_in_months
    assert_operator result[:session].age_band_questionnaire.max_age_months, :<=, current_age
  end

  test "cleanup_stale_sessions is called during service execution" do
    stale_before = @sophia.questionnaire_sessions
      .stale_not_started(@sophia.questionnaire_age_in_months)
      .count
    assert stale_before > 0, "Expected stale sessions before service call"

    DailyMilestoneService.call(@sophia, date: @date)

    stale_after = @sophia.questionnaire_sessions
      .stale_not_started(@sophia.questionnaire_age_in_months)
      .count
    assert_equal 0, stale_after
  end

  test "returns proposed state when no past in-progress sessions exist" do
    # Remove all past in-progress sessions
    @sophia.questionnaire_sessions.in_progress.each do |s|
      s.update!(status: :completed, completed_at: 1.day.ago)
    end

    result = DailyMilestoneService.call(@sophia, date: @date)

    # Should be proposed, completed_today, or all_complete — not finish_previous
    assert_not_equal :finish_previous, result[:state]
    assert_nil result[:session]
  end

  test "result includes milestone key" do
    result = DailyMilestoneService.call(@sophia, date: @date)
    assert result.key?(:milestone)
  end

  test "result includes state key" do
    result = DailyMilestoneService.call(@sophia, date: @date)
    assert result.key?(:state)
  end
end
