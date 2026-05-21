# frozen_string_literal: true

require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "belongs to age_band_questionnaire" do
    question = questions(:m0_com_1)
    assert_equal age_band_questionnaires(:comunicazione_mese_0), question.age_band_questionnaire
  end

  test "has many question_responses" do
    question = questions(:m0_com_1)
    assert_respond_to question, :question_responses
  end

  test "validates presence of prompt" do
    question = Question.new(
      age_band_questionnaire: age_band_questionnaires(:comunicazione_mese_0),
      position: 0
    )
    assert_not question.valid?
    assert question.errors[:prompt].any?
  end

  test "active scope returns only active questions" do
    active_questions = Question.active
    assert active_questions.all?(&:active?)
  end

  test "ordered scope returns questions by position" do
    questions_list = Question.ordered
    positions = questions_list.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "inactive question exists in fixtures" do
    inactive = questions(:inactive_question)
    assert_not inactive.active?
  end

  # --- Content equivalence ---

  test "normalize_prompt strips case, punctuation, and squeezes whitespace" do
    assert_equal "si calma al contatto fisico", Question.normalize_prompt("  Si CALMA al contatto fisico??  ")
    assert_equal "afferra un dito", Question.normalize_prompt("Afferra un dito.")
    assert_nil Question.normalize_prompt(nil)
    assert_nil Question.normalize_prompt("")
  end

  test "with_content_key scope excludes nulls" do
    band = age_band_questionnaires(:motricita_mese_0)
    with_key = Question.create!(age_band_questionnaire: band, prompt: "T1", position: 90, active: true, content_key: "k-1")
    without_key = Question.create!(age_band_questionnaire: band, prompt: "T2", position: 91, active: true, content_key: nil)

    keyed = Question.with_content_key
    assert_includes keyed, with_key
    assert_not_includes keyed, without_key
  end

  test "equivalents returns other questions with same content_key" do
    band_a = age_band_questionnaires(:motricita_mese_0)
    band_b = age_band_questionnaires(:cognizione_mese_0)
    q1 = Question.create!(age_band_questionnaire: band_a, prompt: "P", position: 92, active: true, content_key: "shared-1")
    q2 = Question.create!(age_band_questionnaire: band_b, prompt: "P", position: 92, active: true, content_key: "shared-1")
    q_other = Question.create!(age_band_questionnaire: band_b, prompt: "Q", position: 93, active: true, content_key: "other-key")

    eq = q1.equivalents
    assert_includes eq, q2
    assert_not_includes eq, q1
    assert_not_includes eq, q_other
  end

  test "equivalents returns none when content_key blank" do
    band = age_band_questionnaires(:motricita_mese_0)
    q = Question.create!(age_band_questionnaire: band, prompt: "X", position: 94, active: true, content_key: nil)
    assert_equal 0, q.equivalents.count
  end
end
