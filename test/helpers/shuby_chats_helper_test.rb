# frozen_string_literal: true

require "test_helper"

class ShubyChatsHelperTest < ActionView::TestCase
  test "renders headings as h-tags" do
    assert_includes render_chat_markdown("## Sicurezza"), "<h2>Sicurezza</h2>"
  end

  test "renders unordered lists with separate items" do
    html = render_chat_markdown("- uno\n- due")
    assert_includes html, "<ul>"
    assert_includes html, "<li>uno</li>"
    assert_includes html, "<li>due</li>"
  end

  test "renders bold" do
    assert_includes render_chat_markdown("**forte**"), "<strong>forte</strong>"
  end

  test "renders in-app article links" do
    html = render_chat_markdown("[Articolo](/archive/sonno)")
    assert_includes html, '<a href="/archive/sonno">Articolo</a>'
  end

  test "renders GFM tables" do
    html = render_chat_markdown("| A | B |\n|---|---|\n| 1 | 2 |")
    assert_includes html, "<table>"
    assert_includes html, "<td>1</td>"
  end

  test "neutralizes embedded HTML and scripts" do
    html = render_chat_markdown("Ciao <script>alert(1)</script>")
    refute_includes html, "<script>"
  end

  test "blank input returns an empty html-safe string" do
    assert_equal "", render_chat_markdown("")
    assert_predicate render_chat_markdown(nil), :html_safe?
  end
end
