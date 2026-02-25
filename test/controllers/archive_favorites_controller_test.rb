# frozen_string_literal: true

require "test_helper"

class ArchiveFavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @content = archive_contents(:article_nutrizione)
    @favorited_content = archive_contents(:article_sonno_one)
    sign_in @user
    switch_account(@account)
  end

  # === Create ===

  test "should create favorite" do
    assert_difference("ArchiveFavorite.count", 1) do
      post archive_favorite_path(@content)
    end
    assert_response :redirect
  end

  test "should create favorite via turbo stream" do
    assert_difference("ArchiveFavorite.count", 1) do
      post archive_favorite_path(@content), as: :turbo_stream
    end
    assert_response :success
  end

  test "create is idempotent" do
    assert_difference("ArchiveFavorite.count", 0) do
      post archive_favorite_path(@favorited_content)
    end
    assert_response :redirect
  end

  # === Destroy ===

  test "should destroy favorite" do
    assert_difference("ArchiveFavorite.count", -1) do
      delete archive_favorite_path(@favorited_content)
    end
    assert_response :redirect
  end

  test "should destroy favorite via turbo stream" do
    assert_difference("ArchiveFavorite.count", -1) do
      delete archive_favorite_path(@favorited_content), as: :turbo_stream
    end
    assert_response :success
  end

  test "destroy is idempotent" do
    assert_no_difference("ArchiveFavorite.count") do
      delete archive_favorite_path(@content)
    end
    assert_response :redirect
  end

  # === Authentication ===

  test "requires authentication for create" do
    sign_out @user
    assert_no_difference("ArchiveFavorite.count") do
      post archive_favorite_path(@content)
    end
    assert_response :redirect
  end

  test "requires authentication for destroy" do
    sign_out @user
    assert_no_difference("ArchiveFavorite.count") do
      delete archive_favorite_path(@favorited_content)
    end
    assert_response :redirect
  end

  # === Saved filter ===

  test "saved filter shows favorited content" do
    get archive_index_path(type: "saved")
    assert_response :success
  end
end
