# frozen_string_literal: true

require "test_helper"

class MeasurementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    @measurement = measurements(:sophia_weight_recent)
    sign_in @user
    switch_account(@account)
  end

  # === Index ===

  test "index redirects to child show measurements tab" do
    get child_measurements_path(@child)
    assert_redirected_to child_path(@child, tab: "measurements")
  end

  # === New ===

  test "should get new" do
    get new_child_measurement_path(@child)
    assert_response :success
  end

  test "new accepts type parameter" do
    get new_child_measurement_path(@child, type: "height")
    assert_response :success
  end

  # === Show ===

  test "should get show" do
    get child_measurement_path(@child, @measurement)
    assert_response :success
  end

  test "show renders same-type history and excludes the featured measurement" do
    get child_measurement_path(@child, @measurement)
    assert_response :success
    # Stale weight belongs in the history list (same type, different id)
    assert_match measurements(:sophia_weight_stale).measured_at.strftime("%d . %m . %Y"),
      response.body,
      "expected the stale weight row in the history list"
    # Height is a different type and must NOT appear on the weight detail page
    refute_match measurements(:sophia_height).measured_at.strftime("%d . %m . %Y"),
      response.body,
      "history must be scoped to the featured measurement's type"
  end

  test "requires authentication for show" do
    sign_out @user
    get child_measurement_path(@child, @measurement)
    assert_response :redirect
  end

  test "cannot show measurement for child in another account" do
    sign_out @user
    sign_in users(:two)
    switch_account(accounts(:two))
    get child_measurement_path(@child, @measurement)
    assert_response :not_found
  end

  # === Create ===

  test "should create measurement" do
    # Use 1.day.ago to avoid timezone edge cases with datetime_local format.
    # Weight is entered as kg (DEC-022) and stored as integer grams: "5" -> 5000.
    assert_difference("Measurement.count", 1) do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "5",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M"),
          notes: "After feeding"
        }
      }
    end
    assert_redirected_to child_measurement_path(@child, Measurement.last)
    assert_equal 5000, Measurement.last.value.to_i
  end

  test "create normalizes comma-decimal kg input to grams" do
    assert_difference("Measurement.count", 1) do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "4,5",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")
        }
      }
    end
    assert_equal 4500, Measurement.last.value.to_i
  end

  test "create normalizes period-decimal kg input to grams" do
    assert_difference("Measurement.count", 1) do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "4.5",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")
        }
      }
    end
    assert_equal 4500, Measurement.last.value.to_i
  end

  test "create rejects weight below 500 grams (kg input out of range)" do
    assert_no_difference("Measurement.count") do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "0,3",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")
        }
      }
    end
    assert_response :unprocessable_content
  end

  test "create fails and reports response on invalid data" do
    assert_no_difference("Measurement.count") do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "-1",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")
        }
      }
    end
    assert_response :unprocessable_content
  end

  # === App Store review prompt (native_review_tag, ruby_native >= 0.9.3) ===

  test "saving a measurement renders native_review_tag on the native redirect target" do
    post child_measurements_path(@child), params: {
      measurement: {measurement_type: "weight", value: "5", measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")}
    }
    created = Measurement.last
    assert_redirected_to child_measurement_path(@child, created)
    # Re-request the redirect target with a Ruby Native UA so hotwire_native_app?
    # is true (exercises the UA override); the flash flag set on create persists
    # across the single redirect.
    get child_measurement_path(@child, created), headers: {HTTP_USER_AGENT: "Ruby Native iOS"}
    assert_match "data-native-review", response.body,
      "expected native_review_tag on the post-save page in the native shell"
  end

  test "review prompt stays out of the web DOM after saving a measurement" do
    post child_measurements_path(@child), params: {
      measurement: {measurement_type: "weight", value: "5", measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")}
    }
    get child_measurement_path(@child, Measurement.last)
    refute_match "data-native-review", response.body,
      "native_review_tag must not render on plain web"
  end

  # === Edit ===

  test "should get edit" do
    get edit_child_measurement_path(@child, @measurement)
    assert_response :success
  end

  # === Update ===

  test "should update measurement" do
    # Partial update sends only `value` (no measurement_type); controller falls
    # back to @measurement.measurement_type to know it's a weight in kg.
    patch child_measurement_path(@child, @measurement), params: {
      measurement: {value: "5,1"}
    }
    assert_redirected_to child_measurement_path(@child, @measurement)
    @measurement.reload
    assert_equal 5100, @measurement.value.to_i
  end

  test "should not update measurement with invalid data" do
    patch child_measurement_path(@child, @measurement), params: {
      measurement: {value: "-1"}
    }
    assert_response :unprocessable_content
  end

  # === Destroy ===

  test "should destroy measurement" do
    assert_difference("Measurement.count", -1) do
      delete child_measurement_path(@child, @measurement)
    end
    assert_redirected_to child_path(@child, tab: "measurements")
  end

  # === Photo attachment ===

  test "creates measurement with an attached photo" do
    assert_difference("Measurement.count", 1) do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "5",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M"),
          photo: fixture_file_upload("avatar.jpg", "image/jpeg")
        }
      }
    end
    assert_redirected_to child_measurement_path(@child, Measurement.last)
    assert Measurement.last.photo.attached?
  end

  test "update with remove_photo=1 purges existing photo" do
    @measurement.photo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.jpg")),
      filename: "scale.jpg",
      content_type: "image/jpeg"
    )
    assert @measurement.photo.attached?

    perform_enqueued_jobs do
      patch child_measurement_path(@child, @measurement), params: {
        measurement: {
          measurement_type: @measurement.measurement_type,
          value: @measurement.value_for_form,
          measured_at: @measurement.measured_at.strftime("%Y-%m-%dT%H:%M"),
          remove_photo: "1"
        }
      }
    end
    assert_redirected_to child_measurement_path(@child, @measurement)
    assert_not @measurement.reload.photo.attached?
  end

  test "rejects non-image photo upload" do
    assert_no_difference("Measurement.count") do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "5",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M"),
          photo: fixture_file_upload("not_an_image.txt", "text/plain")
        }
      }
    end
    assert_response :unprocessable_content
  end

  # === Authentication ===

  test "requires authentication for index" do
    sign_out @user
    get child_measurements_path(@child)
    assert_response :redirect
  end

  test "requires authentication for new" do
    sign_out @user
    get new_child_measurement_path(@child)
    assert_response :redirect
  end

  test "requires authentication for create" do
    sign_out @user
    assert_no_difference("Measurement.count") do
      post child_measurements_path(@child), params: {
        measurement: {measurement_type: "weight", value: "4", measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")}
      }
    end
    assert_response :redirect
  end

  # === Authorization / Multi-tenancy ===

  test "cannot access measurements for child in another account" do
    sign_out @user
    sign_in users(:two)
    switch_account(accounts(:two))

    # Sophia belongs to :company account, not :two
    # policy_scope(Child).find raises RecordNotFound → 404 via show_exceptions = :rescuable
    get child_measurements_path(@child)
    assert_response :not_found
  end
end
