# frozen_string_literal: true

require "test_helper"

class ArchiveContentTest < ActiveSupport::TestCase
  test "auto-regenerates slug when title changes" do
    content = archive_contents(:article_sonno_one)
    content.title = "Un Nuovo Titolo"
    content.save!
    assert_equal "un-nuovo-titolo", content.slug
  end
end
