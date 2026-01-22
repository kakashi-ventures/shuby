# frozen_string_literal: true

require "test_helper"

class ChildValidationTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @child = @account.children.build(
      name: "Marco",
      birth_date: 1.year.ago,
      gestational_weeks: 40
    )
  end

  # Age Scope Validation Tests
  test "valid when birth date is within app scope (under 40 months)" do
    @child.birth_date = 35.months.ago
    assert @child.valid?
  end

  test "valid when birth date is exactly 40 months ago" do
    @child.birth_date = 40.months.ago
    assert @child.valid?
  end

  test "invalid when birth date is more than 40 months ago" do
    @child.birth_date = 41.months.ago
    refute @child.valid?
    assert_includes @child.errors[:birth_date], "Il bambino ha più di 40 mesi. Questa app è progettata per bambini fino a 36 mesi (con buffer fino a 40 mesi)"
  end

  test "invalid when birth date is more than 50 months ago" do
    @child.birth_date = 50.months.ago
    refute @child.valid?
    assert_includes @child.errors[:birth_date], "Il bambino ha più di 40 mesi. Questa app è progettata per bambini fino a 36 mesi (con buffer fino a 40 mesi)"
  end

  test "valid when birth date is today" do
    @child.birth_date = Date.current
    assert @child.valid?
  end

  test "invalid when birth date is in the future" do
    @child.birth_date = 1.day.from_now
    refute @child.valid?
    assert_includes @child.errors[:birth_date], "non può essere nel futuro"
  end

  # Whitespace Normalization Tests
  test "strips leading and trailing whitespace from name" do
    @child.name = "  Marco  "
    @child.valid?
    assert_equal "Marco", @child.name
  end

  test "strips leading and trailing whitespace from nickname" do
    @child.name = nil
    @child.nickname = "  Marcuccio  "
    @child.valid?
    assert_equal "Marcuccio", @child.nickname
  end

  test "converts multiple spaces to single space in name" do
    @child.name = "Marco    Antonio"
    @child.valid?
    assert_equal "Marco Antonio", @child.name
  end

  test "strips whitespace from notes" do
    @child.notes = "  Some notes  "
    @child.valid?
    assert_equal "Some notes", @child.notes
  end

  test "handles nil values for text fields" do
    @child.name = "Marco"
    @child.nickname = nil
    @child.notes = nil
    assert @child.valid?
    assert_nil @child.nickname
    assert_nil @child.notes
  end

  # Gestational Age Validation Tests
  test "valid gestational weeks between 22 and 42" do
    @child.gestational_weeks = 37
    assert @child.valid?
  end

  test "invalid gestational weeks below 22" do
    @child.gestational_weeks = 21
    refute @child.valid?
    assert_includes @child.errors[:gestational_weeks], "deve essere compreso tra 22 e 42 settimane"
  end

  test "invalid gestational weeks above 42" do
    @child.gestational_weeks = 43
    refute @child.valid?
    assert_includes @child.errors[:gestational_weeks], "deve essere compreso tra 22 e 42 settimane"
  end

  test "valid gestational days between 0 and 6" do
    @child.gestational_weeks = 37
    @child.gestational_days = 5
    assert @child.valid?
  end

  test "invalid gestational days above 6" do
    @child.gestational_weeks = 37
    @child.gestational_days = 7
    refute @child.valid?
    assert_includes @child.errors[:gestational_days], "deve essere compreso tra 0 e 6 giorni"
  end
end
