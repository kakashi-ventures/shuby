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
end
