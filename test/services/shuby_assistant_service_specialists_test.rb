# frozen_string_literal: true

require "test_helper"

class ShubyAssistantServiceSpecialistsTest < ActiveSupport::TestCase
  setup do
    @chat = shuby_chats(:one)
    @service = ShubyAssistantService.new(@chat)
  end

  # --- Dispatcher Instructions ---

  test "build_system_prompt includes dispatcher instructions" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "ISTRUZIONI DI ROUTING INTERNO"
  end

  test "dispatcher mentions all 7 specialist areas" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "ESPERTO SONNO"
    assert_includes prompt, "ESPERTO ALIMENTAZIONE"
    assert_includes prompt, "ESPERTO MOTRICITÀ"
    assert_includes prompt, "ESPERTO COMUNICAZIONE"
    assert_includes prompt, "ESPERTO BENESSERE FAMIGLIA"
    assert_includes prompt, "ESPERTO SALUTE E PREVENZIONE"
    assert_includes prompt, "ESPERTO GIOCO E SVILUPPO"
  end

  test "dispatcher instructs LLM to never reveal routing" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "non rivelare mai"
    assert_includes prompt, "non menzionare MAI"
  end

  # --- Specialist Sections ---

  test "all 7 specialist sections are present in built prompt" do
    prompt = @service.send(:build_system_prompt)

    ShubyAssistantService::Specialists::ALL_SPECIALIST_SECTIONS.each do |section|
      assert_includes prompt, section.lines.first.strip
    end
  end

  test "each specialist section has required structure" do
    ShubyAssistantService::Specialists::ALL_SPECIALIST_SECTIONS.each do |section|
      assert_includes section, "COMPETENZE:", "Missing COMPETENZE in: #{section.lines.first}"
      assert_includes section, "APPROCCIO:", "Missing APPROCCIO in: #{section.lines.first}"
      assert_includes section, "LINEE GUIDA PER ETÀ:", "Missing LINEE GUIDA in: #{section.lines.first}"
      assert_includes section, "SEGNALI DI ATTENZIONE:", "Missing SEGNALI in: #{section.lines.first}"
    end
  end

  test "each specialist section references pediatra for escalation" do
    ShubyAssistantService::Specialists::ALL_SPECIALIST_SECTIONS.each do |section|
      assert_includes section, "pediatra", "Missing pediatra reference in: #{section.lines.first}"
    end
  end

  # --- Prompt Ordering ---

  test "dispatcher instructions appear before specialist sections" do
    prompt = @service.send(:build_system_prompt)

    dispatcher_pos = prompt.index("ISTRUZIONI DI ROUTING INTERNO")
    specialist_pos = prompt.index("ESPERTO SONNO")

    assert dispatcher_pos < specialist_pos, "Dispatcher should come before specialists"
  end

  test "specialist sections appear before child context when present" do
    prompt = @service.send(:build_system_prompt)

    specialist_pos = prompt.index("ESPERTO GIOCO E SVILUPPO")
    context_pos = prompt.index("CONTESTO BAMBINO:")

    assert_not_nil specialist_pos, "Specialist section should be in prompt"

    if context_pos
      assert specialist_pos < context_pos, "Specialists should come before child context"
    else
      assert_not_includes prompt, "CONTESTO BAMBINO:", "No child context expected for this fixture"
    end
  end

  test "base system prompt is preserved" do
    prompt = @service.send(:build_system_prompt)

    assert_includes prompt, "Shuby, un'assistente esperta in sviluppo infantile"
    assert_includes prompt, "STILE COMUNICATIVO:"
    assert_includes prompt, "SITUAZIONI DI EMERGENZA:"
  end

  # --- Module Constants ---

  test "ALL_SPECIALIST_SECTIONS has exactly 7 entries" do
    assert_equal 7, ShubyAssistantService::Specialists::ALL_SPECIALIST_SECTIONS.size
  end

  test "ALL_SPECIALIST_SECTIONS is frozen" do
    assert ShubyAssistantService::Specialists::ALL_SPECIALIST_SECTIONS.frozen?
  end

  test "specialist_prompt joins all sections" do
    specialist_text = @service.send(:specialist_prompt)

    assert_includes specialist_text, "ESPERTO SONNO"
    assert_includes specialist_text, "ESPERTO GIOCO E SVILUPPO"
    assert specialist_text.length > 500, "Specialist prompt should be substantial"
  end
end
