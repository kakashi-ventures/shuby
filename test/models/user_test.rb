require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user has many accounts" do
    user = users(:one)
    assert_includes user.accounts, accounts(:one)
    assert_includes user.accounts, accounts(:company)
  end

  test "user has a personal account" do
    user = users(:one)
    assert_equal accounts(:one), user.personal_account
  end

  test "can delete user with accounts" do
    assert_difference "User.count", -1 do
      users(:one).destroy
    end
  end

  test "renders name with ActionText to_plain_text" do
    user = users(:one)
    assert_equal user.name, user.attachable_plain_text_representation
  end

  test "can search users by name generated column" do
    assert_equal users(:one), User.search("one").first
  end

  # --- Regression: child "disappears" after editing profile / switching language ---
  # See plan: NULL->"" dirty-tracking on the profile form fired an account-creating
  # callback, stranding the user on a freshly-minted empty personal account.

  test "blank last_name is normalized to nil" do
    user = users(:one)
    user.last_name = ""
    assert_nil user.last_name, "blank last_name must collapse to nil so NULL->'' is a no-op"
  end

  test "changing the name of a user without a personal account does not create one" do
    user = users(:fake_processor) # owns a personal:false account, has no personal account
    assert_nil user.personal_account

    assert_no_difference -> { user.reload.accounts.count } do
      user.update!(first_name: "Renamed")
    end
    assert_nil user.reload.personal_account
  end

  test "submitting the profile form with only a language change creates no account" do
    user = users(:fake_processor)
    user.update_column(:last_name, nil) # legacy state: single-field signup never set last_name
    assert_nil user.personal_account

    # Mimics the profile-edit form: the blank last_name field posts "" over the NULL,
    # and only the language was intentionally changed.
    assert_no_difference -> { user.reload.accounts.count } do
      user.update_without_password(first_name: user.first_name, last_name: "", preferred_language: "it")
    end
    assert_nil user.reload.last_name
  end
end
