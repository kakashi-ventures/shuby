# frozen_string_literal: true

require "test_helper"

class ImagesHelperTest < ActionView::TestCase
  # Stub inline_svg_tag to return a predictable string with the options
  def inline_svg_tag(filename, options = {})
    attrs = options.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    if options[:title]
      "<svg #{attrs}><title>#{options[:title]}</title></svg>"
    else
      "<svg #{attrs}></svg>"
    end
  end

  test "ICON_SIZES contains expected keys" do
    assert_equal %i[xs sm md lg xl xxl], ImagesHelper::ICON_SIZES.keys
  end

  test "render_svg with no options uses fill-current" do
    result = render_svg("shuby/icons/icon-add")
    assert_includes result, 'class="fill-current"'
  end

  test "render_svg with size uses named size classes" do
    result = render_svg("shuby/icons/icon-add", size: :md)
    assert_includes result, "w-5 h-5"
    assert_not_includes result, "fill-current"
  end

  test "render_svg with size and styles combines both" do
    result = render_svg("shuby/icons/icon-add", size: :md, styles: "text-white")
    assert_includes result, "w-5 h-5 text-white"
  end

  test "render_svg with styles only uses styles" do
    result = render_svg("shuby/icons/icon-add", styles: "w-5 h-5 text-red-500")
    assert_includes result, "w-5 h-5 text-red-500"
    assert_not_includes result, "fill-current"
  end

  test "render_svg decorative sets aria-hidden" do
    result = render_svg("shuby/icons/icon-add", size: :md, decorative: true)
    assert_includes result, 'aria_hidden="true"'
    assert_not_includes result, "<title>"
  end

  test "render_svg non-decorative includes title" do
    result = render_svg("shuby/icons/icon-add", size: :md)
    assert_includes result, "<title>Add</title>"
  end

  test "render_svg generates humanized title from icon name" do
    result = render_svg("shuby/icons/icon-arrow-left")
    assert_includes result, "<title>Arrow left</title>"
  end
end
