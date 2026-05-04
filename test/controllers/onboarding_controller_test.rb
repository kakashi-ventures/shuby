# frozen_string_literal: true

require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.personal_account
    # Clean up any existing family profile and children
    @account.family_profile&.destroy
    @account.children.destroy_all
    # Reset onboarding status for these tests
    @user.update!(onboarding_completed_at: nil, onboarding_step: :setup)
    sign_in @user
  end

  test "should get onboarding show page" do
    get onboarding_path
    assert_response :success
    assert_select "h1", /Iniziamo insieme|Let's get started/
  end

  test "should create child and complete onboarding" do
    assert_difference ["Child.count", "FamilyProfile.count"], 1 do
      post onboarding_path, params: {
        child: {
          name: "Marco",
          birth_date: 6.months.ago.to_date,
          sex: "male"
        },
        family_profile: {
          languages_spoken_at_home: 1
        },
        account_user: {
          relationship_to_child: "dad"
        }
      }
    end

    assert_redirected_to root_path
    @user.reload
    @account.reload
    assert @user.onboarding_completed?

    # Check child was created correctly
    child = @account.children.first
    assert_equal "Marco", child.name
    assert_equal "male", child.sex

    # Check family profile was created
    family_profile = @account.family_profile
    assert_equal 1, family_profile.languages_spoken_at_home
    assert_equal "Italia", family_profile.country

    # Check account user relationship was updated
    account_user = @account.account_users.find_by(user: @user)
    assert_equal "dad", account_user.relationship_to_child
  end

  test "should render show on validation errors" do
    post onboarding_path, params: {
      child: {
        name: "",
        birth_date: nil,
        sex: "male"
      },
      family_profile: {
        languages_spoken_at_home: 1
      },
      account_user: {
        relationship_to_child: "dad"
      }
    }

    assert_response :unprocessable_content
  end

  test "should reject future birth date" do
    post onboarding_path, params: {
      child: {
        name: "Marco",
        birth_date: 1.month.from_now.to_date,
        sex: "male"
      },
      family_profile: {
        languages_spoken_at_home: 1
      },
      account_user: {
        relationship_to_child: "dad"
      }
    }

    assert_response :unprocessable_content
  end

  test "should redirect completed user to root" do
    @user.update!(onboarding_completed_at: Time.current)

    get onboarding_path
    assert_redirected_to root_path
  end

  test "should allow intersex option" do
    post onboarding_path, params: {
      child: {
        name: "Alex",
        birth_date: 6.months.ago.to_date,
        sex: "intersex"
      },
      family_profile: {
        languages_spoken_at_home: 2
      },
      account_user: {
        relationship_to_child: "mom"
      }
    }

    assert_redirected_to root_path
    @account.reload
    child = @account.children.first
    assert_equal "intersex", child.sex
  end

  test "should allow grandparent relationship" do
    post onboarding_path, params: {
      child: {
        name: "Test",
        birth_date: 6.months.ago.to_date,
        sex: "male"
      },
      family_profile: {
        languages_spoken_at_home: 1
      },
      account_user: {
        relationship_to_child: "grandparent"
      }
    }

    assert_redirected_to root_path
    account_user = AccountUser.find_by(user: @user, account: @account)
    assert_equal "grandparent", account_user.relationship_to_child
  end

  test "should allow other relationship" do
    post onboarding_path, params: {
      child: {
        name: "Test",
        birth_date: 6.months.ago.to_date,
        sex: "male"
      },
      family_profile: {
        languages_spoken_at_home: 1
      },
      account_user: {
        relationship_to_child: "other"
      }
    }

    assert_redirected_to root_path
    account_user = AccountUser.find_by(user: @user, account: @account)
    assert_equal "other", account_user.relationship_to_child
  end

  test "should allow caregiver relationship" do
    post onboarding_path, params: {
      child: {
        name: "Test",
        birth_date: 6.months.ago.to_date,
        sex: "male"
      },
      family_profile: {
        languages_spoken_at_home: 1
      },
      account_user: {
        relationship_to_child: "caregiver"
      }
    }

    assert_redirected_to root_path
    account_user = AccountUser.find_by(user: @user, account: @account)
    assert_equal "caregiver", account_user.relationship_to_child
  end
end
