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

  # === Game detail (Figma 532:25861 — "05.04_Gioco") ===

  test "game show renders yellow hero band per Figma 532:25861" do
    game = archive_contents(:tip_pianto) # category: Giochi
    get archive_path(game)
    assert_response :success
    assert_match %r{bg-shuby-giallo-400[^"]*pt-16}, response.body,
      "expected game hero to use giallo-400 yellow band, not white or blue"
  end

  test "game show renders tags row with category+age+duration via giallo_scuro variant" do
    game = archive_contents(:tip_pianto)
    get archive_path(game)

    h1_marker = %r{<h1 class="shuby-h2 text-shuby-blue-800 mb-4">}
    pre_h1 = response.body.split(h1_marker, 2).first

    assert_includes pre_h1, "shuby-tag-giallo-scuro",
      "expected category tag to use giallo-500 variant per Figma"
    assert_includes pre_h1, "Giochi", "category label must render"
    assert_includes pre_h1, "0-6 mesi", "age tag must render for game"
    assert_includes pre_h1, "shuby-reading-time-primary",
      "duration must render in game tags row"
    assert_includes pre_h1, "3 min", "duration label must appear"
  end

  test "game show renders recommendations list with blue marker class" do
    game = archive_contents(:tip_pianto)
    get archive_path(game)
    assert_response :success
    assert_includes response.body, "shuby-list-recommendations",
      "expected blue-dot recommendations list class"
    assert_includes response.body, "sonagli morbidi",
      "expected first recommendation body text"
    assert_includes response.body, "<strong>Oggetti consigliati:</strong>",
      "expected **bold** lead phrase to be parsed into <strong>"
  end

  test "game show suppresses Perché è consigliato heading (heading is book-only)" do
    game = archive_contents(:tip_pianto)
    get archive_path(game)
    refute_includes response.body, "Perché è consigliato",
      "recommendations heading is book-only per Figma 532:26226"
  end

  test "game show does NOT mirror bookmark into sticky header" do
    game = archive_contents(:tip_pianto)
    get archive_path(game)

    sticky_marker = %r{shuby-article-sticky-header}
    sticky_section = response.body.split(sticky_marker, 2).last
      &.split(%r{<div data-article-scroll-target="hero">}, 2)
      &.first.to_s

    refute_match %r{archive_favorites.*frame_suffix.*sticky}, sticky_section,
      "tips have empty 88px right slot in sticky header per Figma 532:25886"
    refute_match %r{turbo-frame[^>]+favorite_tip_pianto_sticky}, response.body,
      "regression: sticky favorite frame must not be rendered for tips"
  end

  # === Book detail (Figma 532:26226 — "05.05_Libro") ===

  test "book show renders article-style full-width cover hero (no yellow band)" do
    book = archive_contents(:tip_bagnetto) # category: Lettura
    get archive_path(book)
    assert_response :success
    refute_match %r{bg-shuby-giallo-400[^"]*pt-16}, response.body,
      "book must NOT use the yellow band — Figma 532:26226 shows full-width cover"
    assert_match %r{w-full h-\[269px\] bg-shuby-blue-400 overflow-hidden}, response.body,
      "expected article-style hero container for book per Figma 532:26226"
  end

  test "book show suppresses duration in tags row (Figma 532:26226 has no duration)" do
    book = archive_contents(:tip_bagnetto)
    get archive_path(book)

    h1_marker = %r{<h1 class="shuby-h2 text-shuby-blue-800 mb-2">}
    pre_h1 = response.body.split(h1_marker, 2).first

    assert_includes pre_h1, "Lettura", "category label must render for book"
    refute_includes pre_h1, "shuby-reading-time-primary",
      "books must NOT show duration in tags row per Figma 532:26226"
  end

  test "book show renders compact byline with author + publisher,year" do
    book = archive_contents(:tip_bagnetto)
    get archive_path(book)
    assert_response :success
    assert_includes response.body, "shuby-book-byline-author",
      "expected compact byline class"
    assert_includes response.body, "Elisa Mazzoli, Marianna Balducci",
      "expected author names from fixture"
    assert_match %r{Bacchilega Editore, 2019}, response.body,
      "expected publisher,year line"
  end

  test "book show renders Perché è consigliato heading above recommendations" do
    book = archive_contents(:tip_bagnetto)
    get archive_path(book)
    assert_includes response.body, "Perché è consigliato",
      "expected localized H3 heading for book recommendations per Figma 532:26226"
    assert_includes response.body, "shuby-list-recommendations",
      "recommendations list class must render"
    assert_includes response.body, "<strong>illustrazioni semplici e ad alto contrasto</strong>",
      "expected mid-sentence **bold** to render as <strong>"
  end

  test "book show renders credits block with Autore/Illustrazioni/Editore labels" do
    book = archive_contents(:tip_bagnetto)
    get archive_path(book)
    assert_includes response.body, "shuby-book-credits",
      "expected credits block class"
    assert_includes response.body, "<strong>Autore:</strong>",
      "expected bold Autore label per Figma 532:26226"
    assert_includes response.body, "<strong>Illustrazioni:</strong>",
      "expected bold Illustrazioni label"
    assert_includes response.body, "<strong>Editore:</strong>",
      "expected bold Editore label"
  end

  test "book show renders inline related tips section (Articoli Collegati)" do
    book = archive_contents(:tip_bagnetto)
    get archive_path(book)
    # tip_pianto is age-overlapping (0-6) with tip_bagnetto (0-12) so it should
    # appear in the inline cross-promo section.
    eyebrow = response.body.scan("ARTICOLI COLLEGATI").count
    assert_operator eyebrow, :>=, 2,
      "expected 'ARTICOLI COLLEGATI' eyebrow twice (inline cross-promo + article carousel)"
  end
end
