# frozen_string_literal: true

require "test_helper"

class User::ReportPreferencesTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "every PDF toggle defaults on when preferences are blank" do
    @user.preferences = {}
    User::ReportPreferences::BOOLEAN_KEYS.each do |key|
      assert_equal true, @user.public_send(key), "#{key} should default to true"
    end
  end

  test "casts truthy and falsey writes to real booleans" do
    @user.pdf_pediatrician_measurements = "0"
    assert_equal false, @user.pdf_pediatrician_measurements

    @user.pdf_pediatrician_measurements = "1"
    assert_equal true, @user.pdf_pediatrician_measurements

    @user.pdf_stage_question_details = false
    assert_equal false, @user.pdf_stage_question_details
  end

  test "persists toggles to the preferences JSONB store" do
    @user.update!(pdf_pediatrician_notes: false)
    assert_equal false, @user.reload.pdf_pediatrician_notes
    # Untouched toggles keep their computed default without being stored.
    assert_equal true, @user.pdf_pediatrician_measurements
  end

  test "pdf_pediatrician_sections lists only enabled sections in render order" do
    @user.pdf_pediatrician_measurements = false
    @user.pdf_pediatrician_notes = false

    sections = @user.pdf_pediatrician_sections
    assert_not_includes sections, :measurements
    assert_not_includes sections, :notes
    assert_includes sections, :general_info
    # Order matches the constant (PDF render order).
    assert_equal(User::ReportPreferences::PEDIATRICIAN_SECTIONS & sections, sections)
  end

  test "pdf_pediatrician_sections is the full list by default" do
    @user.preferences = {}
    assert_equal User::ReportPreferences::PEDIATRICIAN_SECTIONS, @user.pdf_pediatrician_sections
  end

  test "selectable sections stay in sync with the report aggregator" do
    assert_equal ReportDataAggregator::SELECTABLE_SECTIONS.sort,
      User::ReportPreferences::PEDIATRICIAN_SECTIONS.sort
  end
end
