# frozen_string_literal: true

require "test_helper"

class GdprDataExportServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "exports valid JSON with all sections" do
    json = GdprDataExportService.new(@user).call
    data = JSON.parse(json)

    assert data.key?("exported_at")
    assert data.key?("user")
    assert data.key?("children")
    assert data.key?("chats")
  end

  test "user section includes name and email" do
    data = JSON.parse(GdprDataExportService.new(@user).call)

    assert_equal @user.name, data["user"]["name"]
    assert_equal @user.email, data["user"]["email"]
  end

  test "children section includes measurements" do
    data = JSON.parse(GdprDataExportService.new(@user).call)

    assert data["children"].is_a?(Array)
    assert data["children"].any?, "Expected at least one child"

    child_data = data["children"].first
    assert child_data.key?("name")
    assert child_data.key?("measurements")
    assert child_data.key?("questionnaires")
  end
end
