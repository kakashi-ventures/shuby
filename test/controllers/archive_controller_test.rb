# frozen_string_literal: true

require "test_helper"

class ArchiveControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    sign_in @user
    switch_account(@account)
  end

  # === Activity detail (Figma 532:24578) ===

  test "activity show renders blue hero band per Figma 532:24578" do
    activity = archive_contents(:activity_tummy_time)
    get archive_path(activity)
    assert_response :success
    assert_match %r{bg-shuby-blue-400[^"]*pt-16}, response.body,
      "expected activity hero to use blue-400 band, not white"
  end

  test "activity show suppresses category + age tags, keeps duration" do
    activity = archive_contents(:activity_tummy_time)
    get archive_path(activity)
    assert_response :success

    # Slice on the H1 element — its class signature is unique to the in-page
    # title (the <head><title> earlier in the doc has different markup). This
    # restricts the assertion to the activity's own tags row, ignoring
    # related-article cards below which legitimately render age tags.
    h1_marker = %r{<h1 class="shuby-h2 text-shuby-blue-800 mb-4">}
    pre_h1 = response.body.split(h1_marker, 2).first
    assert_includes pre_h1, "shuby-reading-time-primary",
      "duration tag must render in the activity's tags row"
    assert_includes pre_h1, "10 min",
      "duration label must appear before the activity title"
    refute_match %r{>0-6 mesi<}, pre_h1,
      "age range tag must be suppressed for activities (Figma 532:24578)"
  end

  test "activity show applies shuby-activity-body wrapper class for blue list markers" do
    activity = archive_contents(:activity_tummy_time)
    activity.update!(body: "<ol><li>Posiziona il bambino</li></ol>")
    get archive_path(activity)
    assert_response :success
    assert_match %r{shuby-article-body[^"]*shuby-activity-body}, response.body,
      "expected activity body to receive both .shuby-article-body and .shuby-activity-body classes"
  end

  test "activity show renders Benefici heart-bullet list when benefits present" do
    activity = archive_contents(:activity_tummy_time)
    get archive_path(activity)
    assert_response :success

    assert_includes response.body, "shuby-list-hearts",
      "expected fucsia heart-bullet list class"
    assert_includes response.body, "Benefici",
      "expected localized 'Benefici' heading"
    assert_includes response.body, "Rinforza il collo e le spalle del bambino.",
      "expected first benefit string from fixture to render"
  end

  # === Article detail (regression check) ===

  test "article show does NOT receive shuby-activity-body class" do
    article = archive_contents(:article_sonno_one)
    get archive_path(article)
    assert_response :success
    refute_includes response.body, "shuby-activity-body",
      "regression: activity-body class must not leak into article detail"
    refute_includes response.body, "shuby-list-hearts",
      "regression: heart-bullet list must not appear on article detail"
  end
end
