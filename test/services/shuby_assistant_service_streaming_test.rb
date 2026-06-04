# frozen_string_literal: true

require "test_helper"

# Streamed deltas from OpenAI often arrive with structural newlines on their own
# ("\n\n" delimiting a paragraph from a "## heading"). Guarding the delta with
# present?/blank? treats those as blank and silently drops them, gluing markdown
# blocks together (e.g. "testo## Titolo"). These tests lock the nil-only guard.
class ShubyAssistantServiceStreamingTest < ActiveSupport::TestCase
  setup do
    @chat = shuby_chats(:one)
    @service = ShubyAssistantService.new(@chat)
  end

  test "handle_text_delta preserves whitespace-only deltas in accumulated text" do
    acc = String.new
    feed(acc, "Testo", "\n\n", "## Titolo")
    assert_equal "Testo\n\n## Titolo", acc
  end

  test "handle_text_delta emits whitespace-only deltas to the stream" do
    emitted = capture_emitted("\n\n")
    assert_equal ["\n\n"], emitted
  end

  test "handle_text_delta skips nil deltas" do
    acc = String.new
    emitted = []
    @service.send(:handle_text_delta, {"delta" => nil}, acc) { |e| emitted << e[:content] }
    assert_equal "", acc
    assert_empty emitted
  end

  test "handle_text_delta strips citation markers from the emitted delta" do
    assert_equal ["ciao"], capture_emitted("ciao【turn0file1】")
  end

  test "handle_text_delta does not emit citation-only deltas" do
    assert_empty capture_emitted("【turn0file1】")
  end

  private

  def feed(acc, *deltas)
    deltas.each { |d| @service.send(:handle_text_delta, {"delta" => d}, acc) {} }
  end

  def capture_emitted(delta)
    emitted = []
    @service.send(:handle_text_delta, {"delta" => delta}, String.new) { |e| emitted << e[:content] }
    emitted
  end
end
