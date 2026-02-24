# frozen_string_literal: true

require "test_helper"

class ShubyAssistantServiceArticleCatalogTest < ActiveSupport::TestCase
  setup do
    @chat = shuby_chats(:one)
    @service = ShubyAssistantService.new(@chat)
  end

  test "build_system_prompt includes article catalog when published content exists" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "CONTENUTI IN-APP DISPONIBILI:"
    assert_includes prompt, "[Titolo](/archivio/slug)"
  end

  test "build_system_prompt omits catalog when no published content" do
    ArchiveContent.update_all(published: false)

    prompt = @service.send(:build_system_prompt)

    assert_not_includes prompt, "CONTENUTI IN-APP DISPONIBILI:"
  end

  test "article catalog only includes published content" do
    prompt = @service.send(:build_system_prompt)

    # Unpublished fixture should not appear
    assert_not_includes prompt, "bozza-non-pubblicata"

    # Published fixture should appear
    assert_includes prompt, "routine-nanna-neonati"
  end

  test "article catalog formats slug-based URLs correctly" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "[Routine della nanna per neonati](/archivio/routine-nanna-neonati)"
    assert_includes prompt, "[Tummy time guidato](/archivio/tummy-time-guidato)"
  end

  test "article catalog groups by content type" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "Articoli:"
    assert_includes prompt, "Attività e Giochi:"
    assert_includes prompt, "Consigli:"
  end

  test "article catalog includes category and age range" do
    prompt = @service.send(:build_system_prompt)

    # Check that category and age_range_label appear in catalog lines
    assert_includes prompt, "| Sonno |"
    assert_includes prompt, "| Motricità |"
    assert_includes prompt, "| 0-6 mesi"
  end
end
