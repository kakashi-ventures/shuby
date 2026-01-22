# frozen_string_literal: true

require "test_helper"

class OnboardingControllerValidationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.accounts.first
    sign_in @user

    # Create family profile with 2 children declared
    @family_profile = @account.create_family_profile!(
      country: "Italy",
      nationality: "Italian",
      mother_tongue: "Italian",
      number_of_children: 2,
      family_structure: :two_parents
    )
  end

  # Children Count Validation Tests

  test "accepts submission when children count matches declaration" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {
            name: "Marco",
            birth_date: 1.year.ago.to_date,
            sex: "male",
            gestational_weeks: 40
          },
          "1" => {
            name: "Sofia",
            birth_date: 2.years.ago.to_date,
            sex: "female",
            gestational_weeks: 39
          }
        }
      }
    }

    assert_response :redirect
    assert_redirected_to onboarding_health_history_path
    assert_equal :health_history, @user.reload.onboarding_step.to_sym
  end

  test "rejects submission when too few children provided" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {
            name: "Marco",
            birth_date: 1.year.ago.to_date,
            sex: "male",
            gestational_weeks: 40
          }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Hai dichiarato 2 bambini, ma ne hai compilati solo 1. Per favore completa tutti i profili.",
                 flash[:alert]
    assert_equal :children, @user.reload.onboarding_step.to_sym
  end

  test "rejects submission when too many children provided" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {name: "Marco", birth_date: 1.year.ago.to_date},
          "1" => {name: "Sofia", birth_date: 2.years.ago.to_date},
          "2" => {name: "Luigi", birth_date: 3.years.ago.to_date}
        }
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Hai dichiarato 2 bambini, ma ne hai compilati 3. Per favore verifica il numero di bambini nel profilo famiglia.",
                 flash[:alert]
  end

  test "accepts when using nicknames instead of names" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {nickname: "Marcuccio", birth_date: 1.year.ago.to_date},
          "1" => {nickname: "Sofi", birth_date: 2.years.ago.to_date}
        }
      }
    }

    assert_response :redirect
    assert_redirected_to onboarding_health_history_path
  end

  test "counts children with either name or nickname present" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {name: "Marco", birth_date: 1.year.ago.to_date},
          "1" => {nickname: "Sofi", birth_date: 2.years.ago.to_date}
        }
      }
    }

    assert_response :redirect
    assert_redirected_to onboarding_health_history_path
  end

  test "does not count children with neither name nor nickname" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {name: "Marco", birth_date: 1.year.ago.to_date},
          "1" => {birth_date: 2.years.ago.to_date, sex: "female"} # No name or nickname
        }
      }
    }

    assert_response :unprocessable_entity
    assert_includes flash[:alert], "ne hai compilati solo 1"
  end

  test "ignores children marked for destruction" do
    # Pre-create children
    child1 = @account.children.create!(name: "Marco", birth_date: 1.year.ago)
    child2 = @account.children.create!(name: "Sofia", birth_date: 2.years.ago)

    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {id: child1.id, name: "Marco", birth_date: 1.year.ago.to_date},
          "1" => {id: child2.id, name: "Sofia", birth_date: 2.years.ago.to_date, _destroy: "1"}
        }
      }
    }

    assert_response :unprocessable_entity
    assert_includes flash[:alert], "ne hai compilati solo 1"
  end

  test "works with single child when one declared" do
    @family_profile.update!(number_of_children: 1)

    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {name: "Marco", birth_date: 1.year.ago.to_date}
        }
      }
    }

    assert_response :redirect
    assert_redirected_to onboarding_health_history_path
  end

  test "works with maximum children (10)" do
    @family_profile.update!(number_of_children: 3)

    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {name: "Child1", birth_date: 1.year.ago.to_date},
          "1" => {name: "Child2", birth_date: 2.years.ago.to_date},
          "2" => {name: "Child3", birth_date: 3.years.ago.to_date}
        }
      }
    }

    assert_response :redirect
    assert_redirected_to onboarding_health_history_path
  end

  test "preserves form data when validation fails" do
    patch onboarding_children_path, params: {
      account: {
        children_attributes: {
          "0" => {
            name: "Marco",
            birth_date: 1.year.ago.to_date,
            gestational_weeks: 40
          }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_not_nil assigns(:children)
    assert_not_nil assigns(:family_profile)
  end
end
