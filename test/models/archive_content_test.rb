# frozen_string_literal: true

require "test_helper"

class ArchiveContentTest < ActiveSupport::TestCase
  test "auto-regenerates slug when title changes" do
    content = archive_contents(:article_sonno_one)
    content.title = "Un Nuovo Titolo"
    content.save!
    assert_equal "un-nuovo-titolo", content.slug
  end

  # benefits_text round-trip — virtual attribute Madmin uses to edit the
  # text[] benefits column as a newline-separated textarea.

  test "benefits_text getter joins benefits array with newlines" do
    content = archive_contents(:activity_tummy_time)
    assert_equal content.benefits.join("\n"), content.benefits_text
  end

  test "benefits_text setter splits on newlines and strips blanks/whitespace" do
    content = archive_contents(:activity_tummy_time)
    content.benefits_text = "  Primo\n\nSecondo  \n   \nTerzo"
    content.save!
    assert_equal ["Primo", "Secondo", "Terzo"], content.reload.benefits
  end

  test "benefits_text= clears benefits when set to blank string" do
    content = archive_contents(:activity_tummy_time)
    content.benefits_text = ""
    content.save!
    assert_equal [], content.reload.benefits
  end

  test "benefits_text getter handles nil benefits gracefully" do
    content = archive_contents(:article_sonno_one) # has no benefits set
    assert_equal "", content.benefits_text
  end

  # recommendations_text round-trip — same Madmin virtual-attr pattern as
  # benefits, used for the Tip "Elenco Puntato" list on the game/book detail
  # screens (Figma 532:25861 / 532:26226).

  test "recommendations_text getter joins recommendations array with newlines" do
    content = archive_contents(:tip_pianto)
    content.recommendations = ["Primo", "Secondo"]
    assert_equal "Primo\nSecondo", content.recommendations_text
  end

  test "recommendations_text setter splits on newlines and strips blanks/whitespace" do
    content = archive_contents(:tip_pianto)
    content.recommendations_text = "  Uno\n\nDue  \n   \nTre"
    content.save!
    assert_equal ["Uno", "Due", "Tre"], content.reload.recommendations
  end

  test "recommendations_text= clears recommendations when set to blank string" do
    content = archive_contents(:tip_pianto)
    content.recommendations = ["Pre-existing"]
    content.recommendations_text = ""
    content.save!
    assert_equal [], content.reload.recommendations
  end

  test "recommendations_text getter handles empty array gracefully" do
    content = archive_contents(:article_sonno_one) # no recommendations
    assert_equal "", content.recommendations_text
  end

  # Tip subtype predicates — used by show.html.erb and per-category partials
  # to dispatch on Lettura (book hero) vs Giochi (yellow band).

  test "category_giochi? returns true only for Tip with Giochi category" do
    assert_predicate archive_contents(:tip_pianto), :category_giochi?
    refute_predicate archive_contents(:tip_bagnetto), :category_giochi?
    refute_predicate archive_contents(:article_sonno_one), :category_giochi?
    refute_predicate archive_contents(:activity_tummy_time), :category_giochi?
  end

  test "category_lettura? returns true only for Tip with Lettura category" do
    assert_predicate archive_contents(:tip_bagnetto), :category_lettura?
    refute_predicate archive_contents(:tip_pianto), :category_lettura?
    refute_predicate archive_contents(:article_sonno_one), :category_lettura?
  end
end
