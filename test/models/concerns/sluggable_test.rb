# frozen_string_literal: true

require "test_helper"

class SluggableTest < ActiveSupport::TestCase
  test "generates slug from slug_source on create when slug is blank" do
    content = ArchiveContent.new(
      title: "Il Mio Primo Libro",
      content_type: :article,
      min_age_months: 0,
      max_age_months: 12
    )
    content.valid?
    assert_equal "il-mio-primo-libro", content.slug
  end

  test "preserves pre-set slug on create (does not overwrite)" do
    content = ArchiveContent.new(
      title: "Comunicazione e Linguaggio",
      slug: "comunicazione-linguaggio",
      content_type: :article,
      min_age_months: 0,
      max_age_months: 12
    )
    content.valid?
    assert_equal "comunicazione-linguaggio", content.slug
  end

  test "regenerates slug when source field changes on update" do
    content = archive_contents(:article_sonno_one)
    content.title = "Nuovo Titolo Aggiornato"
    content.valid?
    assert_equal "nuovo-titolo-aggiornato", content.slug
  end

  test "does not overwrite slug if source field has not changed" do
    content = archive_contents(:article_sonno_one)
    original_slug = content.slug
    content.published = !content.published
    content.valid?
    assert_equal original_slug, content.slug
  end

  test "handles uniqueness collision by appending suffix" do
    ArchiveContent.create!(
      title: "Titolo Unico Per Test",
      content_type: :article,
      min_age_months: 0,
      max_age_months: 12
    )
    second = ArchiveContent.new(
      title: "Titolo Unico Per Test",
      content_type: :article,
      min_age_months: 0,
      max_age_months: 12
    )
    second.valid?
    assert_equal "titolo-unico-per-test-2", second.slug
  end

  test "handles nil source gracefully" do
    content = ArchiveContent.new(title: nil, content_type: :article, min_age_months: 0, max_age_months: 12)
    content.valid?
    assert_nil content.slug
  end

  test "generates slug from overridden slug_source" do
    area = DevelopmentArea.new(name: "Motricità Fine", position: 99)
    area.valid?
    assert_equal "motricita-fine", area.slug
  end

  test "preserves pre-set slug for DevelopmentArea" do
    area = DevelopmentArea.new(
      name: "Comunicazione e Linguaggio",
      slug: "comunicazione-linguaggio",
      position: 99
    )
    area.valid?
    assert_equal "comunicazione-linguaggio", area.slug
  end
end
