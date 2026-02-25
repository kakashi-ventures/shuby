# frozen_string_literal: true

require "test_helper"

class ArchiveFavoriteTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @content = archive_contents(:article_sonno_one)
    @favorite = archive_favorites(:one)
  end

  test "valid favorite" do
    favorite = ArchiveFavorite.new(user: users(:two), archive_content: @content)
    assert favorite.valid?
  end

  test "requires user" do
    favorite = ArchiveFavorite.new(archive_content: @content)
    assert_not favorite.valid?
  end

  test "requires archive content" do
    favorite = ArchiveFavorite.new(user: @user)
    assert_not favorite.valid?
  end

  test "uniqueness scoped to user" do
    duplicate = ArchiveFavorite.new(user: @user, archive_content: @content)
    assert_not duplicate.valid?
    assert duplicate.errors[:archive_content_id].any?
  end

  test "same content can be favorited by different users" do
    favorite = ArchiveFavorite.new(user: users(:two), archive_content: @content)
    assert favorite.valid?
  end

  test "dependent destroy from user" do
    assert_difference("ArchiveFavorite.count", -2) do
      @user.destroy
    end
  end

  test "dependent destroy from archive content" do
    assert_difference("ArchiveFavorite.count", -1) do
      @content.destroy
    end
  end

  test "user has_many favorite_archive_contents" do
    assert_includes @user.favorite_archive_contents, @content
  end
end
