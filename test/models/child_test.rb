# frozen_string_literal: true

require "test_helper"

class ChildTest < ActiveSupport::TestCase
  test "valid child" do
    child = Child.new(
      account: accounts(:company),
      name: "Test Child",
      birth_date: 1.year.ago.to_date
    )
    assert child.valid?
  end

  test "requires name" do
    child = Child.new(
      account: accounts(:company),
      birth_date: 1.year.ago.to_date
    )
    assert_not child.valid?
    assert child.errors[:name].any?
  end

  test "requires birth_date" do
    child = Child.new(
      account: accounts(:company),
      name: "Test Child"
    )
    assert_not child.valid?
    assert child.errors[:birth_date].any?
  end

  test "birth_date cannot be in future" do
    child = Child.new(
      account: accounts(:company),
      name: "Test Child",
      birth_date: 1.day.from_now.to_date
    )
    assert_not child.valid?
    assert child.errors[:birth_date].present?
  end

  test "gestational_weeks must be between 22 and 42" do
    child = Child.new(
      account: accounts(:company),
      name: "Test Child",
      birth_date: 1.year.ago.to_date,
      gestational_weeks: 20
    )
    assert_not child.valid?
    assert child.errors[:gestational_weeks].present?
  end

  test "gestational_days must be between 0 and 6" do
    child = Child.new(
      account: accounts(:company),
      name: "Test Child",
      birth_date: 1.year.ago.to_date,
      gestational_weeks: 34,
      gestational_days: 8
    )
    assert_not child.valid?
    assert child.errors[:gestational_days].present?
  end

  test "premature? returns true for gestational_weeks < 37" do
    child = children(:luca)
    assert child.premature?
  end

  test "premature? returns false for term babies" do
    child = children(:sophia)
    assert_not child.premature?
  end

  test "age_in_months calculates correctly" do
    child = Child.new(birth_date: 18.months.ago.to_date)
    assert_in_delta 18, child.age_in_months, 1
  end

  test "age_display shows months for babies under 2 years" do
    child = Child.new(birth_date: 6.months.ago.to_date)
    # Match English "month" or Italian "mesi/mese"
    assert_match(/month|mes/i, child.age_display)
  end

  test "age_display shows years for children 2 and over" do
    child = Child.new(birth_date: 3.years.ago.to_date)
    # Match English "year" or Italian "anni/anno"
    assert_match(/year|ann/i, child.age_display)
  end

  test "active scope returns only active children" do
    assert_includes Child.active, children(:sophia)
    assert_not_includes Child.active, children(:marco_inactive)
  end

  test "detailed_age_display_at uses corrected birth date for premature babies under 24 months" do
    # Luca is preterm (34w2d gestational) and 18 months chronological → corrected-age regime.
    child = children(:luca)
    # Pick a date that makes the chronological vs corrected difference visible:
    # 100 days after birth_date. Chronological = 100 days ≈ 14 weeks 2 days.
    # Corrected removes (40 - 34) * 7 + (7 - 2) = 47 days of prematurity,
    # yielding ~53 days ≈ 7 weeks 4 days.
    measured = child.birth_date + 100.days

    chronological_weeks = 100 / 7                     # 14
    corrected_weeks = (100 - 47) / 7              # 7
    display = child.detailed_age_display_at(measured)

    assert_match(/\b#{corrected_weeks}\b/, display, "expected corrected-age weeks (#{corrected_weeks})")
    refute_match(/\b#{chronological_weeks}\b/, display, "chronological-age weeks (#{chronological_weeks}) must not leak through")
  end

  test "detailed_age_display_at uses chronological age for term babies" do
    child = children(:sophia) # term baby (no gestational_weeks)
    measured = child.birth_date + 42.days          # 6 weeks exactly
    assert_match(/\b6\b/, child.detailed_age_display_at(measured))
  end

  test "age_reference_date returns corrected birth date for premature under 24 months" do
    child = children(:luca) # 34w2d gestational, 18mo chronological
    measured = child.birth_date + 100.days

    # Premature with chronological age (at the measurement date) < 24 months
    # → reference date should be corrected_birth_date, NOT raw birth_date.
    # corrected_birth_date offsets birth by (40-34)*7 + (7-2) = 47 days.
    expected_offset = ((40 - 34) * 7) + (7 - 2)
    assert_equal child.birth_date + expected_offset.days, child.age_reference_date(measured)
    refute_equal child.birth_date, child.age_reference_date(measured)
  end

  test "age_reference_date returns raw birth date for term babies" do
    child = children(:sophia) # term, no gestational_weeks
    measured = child.birth_date + 100.days
    assert_equal child.birth_date, child.age_reference_date(measured)
  end

  test "age_reference_date falls back to raw birth date once premature baby passes 24 chronological months" do
    # Use a fresh fixture clone to push age past the 24-month corrected-age window.
    old_preemie = Child.create!(
      account: accounts(:company),
      name: "Old Preemie Test",
      birth_date: 30.months.ago.to_date,
      gestational_weeks: 34,
      gestational_days: 2,
      sex: 1
    )
    measured = Date.current
    assert_equal old_preemie.birth_date, old_preemie.age_reference_date(measured)
  end
end
