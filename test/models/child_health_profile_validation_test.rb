# frozen_string_literal: true

require "test_helper"

class ChildHealthProfileValidationTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @child = @account.children.create!(
      name: "Marco",
      birth_date: 1.year.ago,
      gestational_weeks: 40
    )
    @health_profile = @child.build_health_profile
  end

  # Prematurity Logic Validation Tests

  test "valid when term baby (37+ weeks) has no premature-specific fields" do
    @child.update!(gestational_weeks: 40)
    @health_profile.birth_weight_under_1500 = :weight_no
    @health_profile.required_oxygen_ventilation = :oxygen_no
    assert @health_profile.valid?
  end

  test "valid when term baby has unknown values for premature fields" do
    @child.update!(gestational_weeks: 38)
    @health_profile.birth_weight_under_1500 = :weight_unknown
    @health_profile.required_oxygen_ventilation = :oxygen_unknown
    assert @health_profile.valid?
  end

  test "invalid when term baby (37+ weeks) has birth_weight_under_1500 as yes" do
    @child.update!(gestational_weeks: 40)
    @health_profile.birth_weight_under_1500 = :weight_yes
    refute @health_profile.valid?
    assert_includes @health_profile.errors[:birth_weight_under_1500],
                    "Questo campo è rilevante solo per i neonati prematuri (< 37 settimane)"
  end

  test "invalid when term baby (37+ weeks) required oxygen ventilation" do
    @child.update!(gestational_weeks: 39)
    @health_profile.required_oxygen_ventilation = :oxygen_yes
    refute @health_profile.valid?
    assert_includes @health_profile.errors[:required_oxygen_ventilation],
                    "Questo campo è rilevante solo per i neonati prematuri (< 37 settimane)"
  end

  test "invalid when term baby has premature follow-ups scheduled" do
    @child.update!(gestational_weeks: 38)
    @health_profile.scheduled_followups = ["hearing", "vision", "motor"]
    refute @health_profile.valid?
    assert_includes @health_profile.errors[:scheduled_followups],
                    "I follow-up per prematuri (hearing, vision, motor) non sono applicabili ai bambini nati a termine (≥ 37 settimane)"
  end

  test "valid when premature baby (< 37 weeks) has premature-specific fields" do
    @child.update!(gestational_weeks: 32)
    @health_profile.birth_weight_under_1500 = :weight_yes
    @health_profile.required_oxygen_ventilation = :oxygen_yes
    @health_profile.scheduled_followups = ["hearing", "vision", "motor", "respiratory"]
    assert @health_profile.valid?
  end

  test "valid when premature baby (36 weeks) has appropriate fields" do
    @child.update!(gestational_weeks: 36)
    @health_profile.birth_weight_under_1500 = :weight_no
    @health_profile.required_oxygen_ventilation = :oxygen_yes
    @health_profile.scheduled_followups = ["hearing"]
    assert @health_profile.valid?
  end

  test "valid when term baby at exactly 37 weeks has no premature fields" do
    @child.update!(gestational_weeks: 37)
    @health_profile.birth_weight_under_1500 = :weight_no
    @health_profile.required_oxygen_ventilation = :oxygen_no
    @health_profile.scheduled_followups = []
    assert @health_profile.valid?
  end

  test "invalid when term baby at 37 weeks has premature follow-ups" do
    @child.update!(gestational_weeks: 37)
    @health_profile.scheduled_followups = ["hearing", "respiratory"]
    refute @health_profile.valid?
    assert_includes @health_profile.errors[:scheduled_followups],
                    "I follow-up per prematuri (hearing, respiratory) non sono applicabili ai bambini nati a termine (≥ 37 settimane)"
  end

  test "valid when term baby has followup_other (not premature-specific)" do
    @child.update!(gestational_weeks: 40)
    @health_profile.scheduled_followups = ["followup_other"]
    assert @health_profile.valid?
  end

  test "skips validation when gestational_weeks is not set" do
    @child.update!(gestational_weeks: nil)
    @health_profile.birth_weight_under_1500 = :weight_yes
    @health_profile.required_oxygen_ventilation = :oxygen_yes
    assert @health_profile.valid?
  end

  test "skips validation when child is not present" do
    @health_profile.child = nil
    @health_profile.birth_weight_under_1500 = :weight_yes
    # This will fail on belongs_to validation, not our custom validation
    refute @health_profile.valid?
    refute_includes @health_profile.errors[:birth_weight_under_1500],
                    "Questo campo è rilevante solo per i neonati prematuri (< 37 settimane)"
  end
end
