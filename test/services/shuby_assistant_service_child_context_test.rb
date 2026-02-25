# frozen_string_literal: true

require "test_helper"

class ShubyAssistantServiceChildContextTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @emma = children(:emma)
    @matteo = children(:matteo)
  end

  test "child_context_prompt uses the chat's associated child" do
    chat = shuby_chats(:one)
    chat.update!(child: @matteo)
    service = ShubyAssistantService.new(chat)

    prompt = service.send(:child_context_prompt)

    assert_includes prompt, "Matteo"
    assert_not_includes prompt, "Emma"
  end

  test "child_context_prompt falls back to first child when child_id is nil" do
    chat = shuby_chats(:one)
    chat.update!(child: nil)
    service = ShubyAssistantService.new(chat)

    prompt = service.send(:child_context_prompt)

    # Emma comes first alphabetically
    assert_includes prompt, "Emma"
  end

  test "child_context_prompt returns nil when no children exist" do
    chat = shuby_chats(:two)
    service = ShubyAssistantService.new(chat)

    prompt = service.send(:child_context_prompt)

    assert_nil prompt
  end

  test "create_for_user links the specified child to the chat" do
    user = users(:one)

    service = ShubyAssistantService.create_for_user(user, child: @matteo)
    chat = service.instance_variable_get(:@shuby_chat)

    assert_equal @matteo, chat.child
  end

  test "shuby_chat validates child belongs to same account" do
    chat = shuby_chats(:one)
    other_child = children(:sophia) # belongs to :company account

    chat.child = other_child
    assert_not chat.valid?
    assert chat.errors[:child].any?
  end

  test "create_for_user defaults to first child when no child specified" do
    user = users(:one)

    service = ShubyAssistantService.create_for_user(user)
    chat = service.instance_variable_get(:@shuby_chat)

    # Emma is alphabetically first
    assert_equal @emma, chat.child
  end
end
