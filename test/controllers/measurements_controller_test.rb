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

  # === Create ===

  test "should create measurement" do
    # Use 1.day.ago to avoid timezone edge cases with datetime_local format
    assert_difference("Measurement.count", 1) do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "5000",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M"),
          notes: "After feeding"
        }
      }
    end
    assert_redirected_to child_path(@child, tab: "measurements")
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

  # === Edit ===

  test "should get edit" do
    get edit_child_measurement_path(@child, @measurement)
    assert_response :success
  end

  # === Update ===

  test "should update measurement" do
    patch child_measurement_path(@child, @measurement), params: {
      measurement: {value: "5100"}
    }
    assert_redirected_to child_path(@child, tab: "measurements")
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
          value: "5000",
          measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M"),
          photo: fixture_file_upload("avatar.jpg", "image/jpeg")
        }
      }
    end
    assert_redirected_to child_path(@child, tab: "measurements")
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
          value: @measurement.value,
          measured_at: @measurement.measured_at.strftime("%Y-%m-%dT%H:%M"),
          remove_photo: "1"
        }
      }
    end
    assert_redirected_to child_path(@child, tab: "measurements")
    assert_not @measurement.reload.photo.attached?
  end

  test "rejects non-image photo upload" do
    assert_no_difference("Measurement.count") do
      post child_measurements_path(@child), params: {
        measurement: {
          measurement_type: "weight",
          value: "5000",
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
        measurement: {measurement_type: "weight", value: "4000", measured_at: 1.day.ago.strftime("%Y-%m-%dT%H:%M")}
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
