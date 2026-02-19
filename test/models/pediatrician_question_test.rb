# frozen_string_literal: true

require "test_helper"

class PediatricianQuestionTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid question" do
    q = PediatricianQuestion.new(child: children(:sophia), body: "Domanda per il pediatra")
    assert q.valid?
  end

  test "requires body" do
    q = PediatricianQuestion.new(child: children(:sophia), body: nil)
    assert_not q.valid?
    assert q.errors[:body].any?
  end

  test "requires child" do
    q = PediatricianQuestion.new(body: "Domanda")
    assert_not q.valid?
    assert q.errors[:child].any?
  end

  test "body cannot exceed 500 characters" do
    q = PediatricianQuestion.new(child: children(:sophia), body: "x" * 501)
    assert_not q.valid?
    assert q.errors[:body].any?
  end

  test "body at 500 characters is valid" do
    q = PediatricianQuestion.new(child: children(:sophia), body: "x" * 500)
    assert q.valid?
  end

  # === Scopes ===

  test "ordered scope sorts by position then created_at" do
    questions = children(:sophia).pediatrician_questions.ordered
    assert_equal 0, questions.first.position
    assert_equal 1, questions.last.position
  end

  # === Associations ===

  test "belongs to child" do
    q = pediatrician_questions(:sophia_question_one)
    assert_equal children(:sophia), q.child
  end

  test "destroyed when child is destroyed" do
    child = children(:sophia)
    question_ids = child.pediatrician_questions.pluck(:id)
    assert question_ids.any?

    child.destroy
    question_ids.each do |id|
      assert_nil PediatricianQuestion.find_by(id: id)
    end
  end

  # === Default values ===

  test "position defaults to 0" do
    q = PediatricianQuestion.new(child: children(:sophia), body: "Test question")
    assert_equal 0, q.position
  end
end
