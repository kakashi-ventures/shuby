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
end
