# frozen_string_literal: true

require "test_helper"

class FamilyProfileTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test "valid family profile" do
    profile = FamilyProfile.new(
      account: @account,
      country: "Italy",
      nationality: "Italian",
      mother_tongue: "Italian",
      family_structure: :two_parents,
      number_of_children: 2,
      languages_spoken_at_home: 1
    )
    assert profile.valid?
  end

  test "requires country" do
    profile = FamilyProfile.new(
      account: @account,
      number_of_children: 1,
      languages_spoken_at_home: 1
    )
    assert_not profile.valid?
    assert profile.errors[:country].any?
  end

  test "requires positive number of children" do
    profile = FamilyProfile.new(
      account: @account,
      country: "Italy",
      number_of_children: 0,
      languages_spoken_at_home: 1
    )
    assert_not profile.valid?
    assert profile.errors[:number_of_children].any?
  end

  test "limits number of children to 10" do
    profile = FamilyProfile.new(
      account: @account,
      country: "Italy",
      number_of_children: 11,
      languages_spoken_at_home: 1
    )
    assert_not profile.valid?
    assert profile.errors[:number_of_children].any?
  end

  test "family structure enum" do
    profile = FamilyProfile.new(account: @account, country: "Italy", number_of_children: 1, languages_spoken_at_home: 1)

    profile.family_structure = :single_parent
    assert profile.family_structure_single_parent?

    profile.family_structure = :two_parents
    assert profile.family_structure_two_parents?

    profile.family_structure = :foster
    assert profile.family_structure_foster?

    profile.family_structure = :adoptive
    assert profile.family_structure_adoptive?
  end

  test "two parents type enum" do
    profile = FamilyProfile.new(account: @account, country: "Italy", number_of_children: 1, languages_spoken_at_home: 1)

    profile.two_parents_type = :male_male
    assert profile.two_parents_type_male_male?

    profile.two_parents_type = :female_female
    assert profile.two_parents_type_female_female?

    profile.two_parents_type = :prefer_not_to_say
    assert profile.two_parents_type_prefer_not_to_say?
  end

  test "caregivers list returns empty array when nil" do
    profile = FamilyProfile.new(account: @account, country: "Italy", number_of_children: 1, languages_spoken_at_home: 1)
    assert_equal [], profile.caregivers_list
  end

  test "hereditary conditions list returns empty array when nil" do
    profile = FamilyProfile.new(account: @account, country: "Italy", number_of_children: 1, languages_spoken_at_home: 1)
    assert_equal [], profile.hereditary_conditions_list
  end

  test "stores and retrieves primary caregivers" do
    profile = FamilyProfile.create!(
      account: @account,
      country: "Italy",
      number_of_children: 1,
      languages_spoken_at_home: 1,
      primary_caregivers: ["parents", "grandparents"]
    )
    profile.reload
    assert_equal ["parents", "grandparents"], profile.caregivers_list
  end

  test "stores and retrieves hereditary conditions" do
    profile = FamilyProfile.create!(
      account: @account,
      country: "Italy",
      number_of_children: 1,
      languages_spoken_at_home: 1,
      has_hereditary_conditions: true,
      hereditary_conditions: ["language_difficulties", "autism_spectrum"]
    )
    profile.reload
    assert_equal ["language_difficulties", "autism_spectrum"], profile.hereditary_conditions_list
  end
end
