# frozen_string_literal: true

require "test_helper"

class TimelineHelperTest < ActionView::TestCase
  include TimelineHelper

  setup do
    @child = children(:sophia)
    @area = development_areas(:motricita)
  end

  # === timeline_card_destination — mirrors the removed _section_session_status ===

  test "past completed session points to the results page (full nav)" do
    session = questionnaire_sessions(:completed_session)
    dest = timeline_card_destination(@child, @area, session, :past)

    assert_equal child_questionnaire_session_path(@child, session), dest[:path]
    assert_not dest[:overlay]
  end

  test "completed current session points to the results page (full nav)" do
    session = questionnaire_sessions(:completed_session)
    dest = timeline_card_destination(@child, @area, session, :current)

    assert_equal child_questionnaire_session_path(@child, session), dest[:path]
    assert_not dest[:overlay]
  end

  test "no session opens the questionnaire overlay via the start action" do
    dest = timeline_card_destination(@child, @area, nil, :current)

    assert_equal start_child_development_stage_path(@child, @area.slug), dest[:path]
    assert dest[:overlay]
  end

  test "not-started session opens the overlay frame directly" do
    session = questionnaire_sessions(:not_started_session)
    dest = timeline_card_destination(@child, @area, session, :current)

    assert_equal overlay_frame_child_questionnaire_session_path(@child, session), dest[:path]
    assert dest[:overlay]
  end

  test "partially answered session resumes in the overlay" do
    session = questionnaire_sessions(:in_progress_session)
    session.stub(:all_answered?, false) do
      dest = timeline_card_destination(@child, @area, session, :current)

      assert_equal overlay_frame_child_questionnaire_session_path(@child, session), dest[:path]
      assert dest[:overlay]
    end
  end

  test "fully answered (but not completed) session points to the results page" do
    session = questionnaire_sessions(:in_progress_session)
    session.stub(:all_answered?, true) do
      dest = timeline_card_destination(@child, @area, session, :current)

      assert_equal child_questionnaire_session_path(@child, session), dest[:path]
      assert_not dest[:overlay]
    end
  end
end
