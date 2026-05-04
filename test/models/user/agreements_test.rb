require "test_helper"

class User::AgreementsTest < ActiveSupport::TestCase
  setup do
    @valid_attrs = {
      name: "Test",
      email: "agreements_test@example.com",
      password: "TestPassword",
      terms_of_service: "1",
      informed_consent: "1"
    }
  end

  test "user creation succeeds with all required consents" do
    user = User.new(@valid_attrs)
    assert user.valid?, user.errors.full_messages.to_sentence
  end

  test "user creation fails without terms_of_service" do
    user = User.new(@valid_attrs.merge(terms_of_service: "0"))
    assert_not user.valid?
    assert user.errors[:terms_of_service].any?
  end

  test "user creation fails without informed_consent" do
    user = User.new(@valid_attrs.merge(informed_consent: "0"))
    assert_not user.valid?
    assert user.errors[:informed_consent].any?
  end

  test "successful create sets accepted timestamps for all three agreements" do
    user = User.create!(@valid_attrs)
    assert_not_nil user.accepted_terms_at
    assert_not_nil user.accepted_privacy_at
    assert_not_nil user.accepted_informed_consent_at
  end

  test "research_consent_anonymized=true sets timestamp at signup" do
    user = User.create!(@valid_attrs.merge(research_consent_anonymized: "1"))
    assert_not_nil user.research_consent_anonymized_at
    assert user.research_consent_anonymized
  end

  test "research_consent_anonymized=false leaves timestamp nil at signup" do
    user = User.create!(@valid_attrs.merge(research_consent_anonymized: "0"))
    assert_nil user.research_consent_anonymized_at
    assert_not user.research_consent_anonymized
  end

  test "toggling research consent off sets timestamp to nil" do
    user = User.create!(@valid_attrs.merge(research_consent_anonymized: "1"))
    user.update!(research_consent_anonymized: "0")
    assert_nil user.research_consent_anonymized_at
    assert_not user.research_consent_anonymized
  end

  test "toggling research consent on after signup sets timestamp" do
    user = User.create!(@valid_attrs)
    assert_nil user.research_consent_anonymized_at
    user.update!(research_consent_anonymized: "1")
    assert_not_nil user.research_consent_anonymized_at
    assert user.research_consent_anonymized
  end

  test "research_consent_anonymized getter reflects timestamp state" do
    user = User.create!(@valid_attrs)
    assert_not user.research_consent_anonymized
    user.update_column(:research_consent_anonymized_at, Time.current)
    assert user.research_consent_anonymized
  end
end
