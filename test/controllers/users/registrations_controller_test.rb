require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include InvisibleCaptcha

  setup do
    @user_params = {user:
                        {name: "Test User",
                         email: "user@test.com",
                         password: "TestPassword",
                         terms_of_service: "1",
                         informed_consent: "1"}}

    # With this feature enabled, we also need to submit an account
    if Jumpstart.config.register_with_account?
      @user_params[:user][:owned_accounts_attributes] = [{name: "Test Account"}]
    end
  end

  class BasicRegistrationTest < Users::RegistrationsControllerTest
    test "successfully registration form render" do
      get new_user_registration_path
      assert_response :success
      assert_includes response.body, "user[name]"
      assert_includes response.body, "user[email]"
      assert_includes response.body, "user[password]"
      assert_includes response.body, InvisibleCaptcha.sentence_for_humans
    end

    test "successful user registration" do
      assert_difference "User.count" do
        post user_registration_url, params: @user_params
      end
    end

    test "failed user registration" do
      assert_no_difference "User.count" do
        post user_registration_url, params: {}
      end
    end

    test "registration fails without informed consent" do
      params = @user_params.deep_dup
      params[:user][:informed_consent] = "0"
      assert_no_difference "User.count" do
        post user_registration_url, params: params
      end
    end

    test "successful registration sets all consent timestamps" do
      params = @user_params.deep_dup
      params[:user][:research_consent_anonymized] = "1"
      assert_difference "User.count" do
        post user_registration_url, params: params
      end
      user = User.find_by(email: "user@test.com")
      assert_not_nil user.accepted_terms_at
      assert_not_nil user.accepted_privacy_at
      assert_not_nil user.accepted_informed_consent_at
      assert_not_nil user.research_consent_anonymized_at
    end

    test "research consent stays nil when checkbox is not selected" do
      assert_difference "User.count" do
        post user_registration_url, params: @user_params
      end
      user = User.find_by(email: "user@test.com")
      assert_nil user.research_consent_anonymized_at
    end
  end

  class InvibleCaptchaTest < Users::RegistrationsControllerTest
    test "honeypot is not filled and user creation succeeds" do
      assert_difference "User.count" do
        post user_registration_url, params: @user_params.merge(honeypotx: "")
      end
    end

    test "honeypot is filled and user creation fails" do
      assert_no_difference "User.count" do
        post user_registration_url, params: @user_params.merge(honeypotx: "spam")
      end
    end
  end

  class RegisterWithAccountTest < Users::RegistrationsControllerTest
    test "doesn't prompt for account details on sign up if disabled" do
      Jumpstart.config.stub(:register_with_account?, false) do
        get new_user_registration_path
        assert_no_match I18n.t("helpers.label.account.name"), response.body
      end
    end

    test "prompts for account details on sign up if enabled" do
      Jumpstart.config.stub(:register_with_account?, true) do
        get new_user_registration_path
        assert_select "label", text: I18n.t("helpers.label.account.name")
      end
    end
  end
end
