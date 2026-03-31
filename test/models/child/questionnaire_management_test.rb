# frozen_string_literal: true

require "test_helper"

class Child::QuestionnaireManagementTest < ActiveSupport::TestCase
  setup do
    @sophia = children(:sophia)
    @current_age = @sophia.questionnaire_age_in_months
  end

  test "in_progress_past_sessions returns in-progress sessions from past months" do
    past_sessions = @sophia.in_progress_past_sessions
    assert past_sessions.any?, "Expected past in-progress sessions"
    past_sessions.each do |s|
      assert s.in_progress?
      assert_operator s.age_band_questionnaire.max_age_months, :<=, @current_age
    end
  end

  test "in_progress_past_sessions includes development_area association" do
    past_sessions = @sophia.in_progress_past_sessions
    # Should be eager loaded — no additional query
    past_sessions.each do |s|
      assert_not_nil s.age_band_questionnaire.development_area
    end
  end

  test "cleanup_stale_sessions! destroys not_started sessions from past months" do
    stale_count = @sophia.questionnaire_sessions
      .stale_not_started(@current_age)
      .count
    assert stale_count > 0, "Expected stale sessions to exist before cleanup"

    assert_difference -> { @sophia.questionnaire_sessions.count }, -stale_count do
      @sophia.cleanup_stale_sessions!
    end

    remaining_stale = @sophia.questionnaire_sessions
      .stale_not_started(@current_age)
      .count
    assert_equal 0, remaining_stale
  end

  test "cleanup_stale_sessions! does not destroy in-progress past sessions" do
    in_progress_past = @sophia.in_progress_past_sessions.to_a
    assert in_progress_past.any?, "Expected in-progress past sessions"

    @sophia.cleanup_stale_sessions!

    in_progress_past.each do |s|
      assert QuestionnaireSession.exists?(s.id), "In-progress session #{s.id} should not be destroyed"
    end
  end

  test "start_new_session raises error for past age band" do
    past_questionnaire = age_band_questionnaires(:comunicazione_mese_1)
    assert_operator past_questionnaire.max_age_months, :<=, @current_age

    error = assert_raises(ArgumentError) do
      @sophia.start_new_session(past_questionnaire)
    end
    assert_equal "Cannot start session for past age band", error.message
  end

  test "start_new_session succeeds for current age band" do
    current_questionnaire = AgeBandQuestionnaire.for_age(@current_age).first
    return unless current_questionnaire

    assert_difference -> { @sophia.questionnaire_sessions.count }, 1 do
      session = @sophia.start_new_session(current_questionnaire)
      assert session.not_started?
      assert_equal current_questionnaire, session.age_band_questionnaire
    end
  end
end
