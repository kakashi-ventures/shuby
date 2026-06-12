# frozen_string_literal: true

require "test_helper"

# The in-app "Installa l'app" surfaces (dashboard banner + settings row) must
# render on the web but disappear inside the native iOS shell. Standalone
# (installed-PWA) hiding is client-side CSS — exercised in the system test.
class PwaInstallTest < ActionDispatch::IntegrationTest
  # Matches the /(Turbo|Hotwire|Ruby) Native/ regex in
  # app/controllers/concerns/authentication.rb#hotwire_native_app?.
  NATIVE_UA = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) Ruby Native/0.10.2"
  BANNER_MARKER = 'data-pwa-install-target="banner"'

  setup do
    @user = users(:one)
    sign_in @user
  end

  # === Service worker ===

  test "service worker is served as javascript with a fetch handler" do
    get "/service-worker.js"

    assert_response :success
    assert_match(/javascript/, response.media_type)
    assert_includes response.body, 'addEventListener("fetch"'
  end

  # === Head wiring ===

  test "head ships the standalone detection class and PWA install meta tags" do
    get today_path

    assert_response :success
    assert_includes response.body, "pwa-standalone"
    assert_includes response.body, "apple-mobile-web-app-capable"
    assert_includes response.body, 'name="theme-color"'
  end

  # === Web surfaces present ===

  test "dashboard renders the install banner on the web" do
    get today_path

    assert_response :success
    assert_includes response.body, BANNER_MARKER
    assert_includes response.body, I18n.t("pwa.install.banner.title")
  end

  test "settings configuration tab renders the install row on the web" do
    get settings_path(tab: "configuration")

    assert_response :success
    # Rendered via t() in ERB, so the apostrophe in "l'app" is HTML-escaped.
    assert_includes response.body, ERB::Util.html_escape(I18n.t("pwa.install.settings.label"))
  end

  # === Hidden in the native iOS shell ===

  test "dashboard omits the install banner in the native shell" do
    get today_path, headers: {"User-Agent" => NATIVE_UA}

    assert_response :success
    assert_not_includes response.body, BANNER_MARKER
    assert_not_includes response.body, I18n.t("pwa.install.banner.title")
  end

  test "settings configuration tab omits the install row in the native shell" do
    get settings_path(tab: "configuration"), headers: {"User-Agent" => NATIVE_UA}

    assert_response :success
    assert_not_includes response.body, ERB::Util.html_escape(I18n.t("pwa.install.settings.label"))
  end
end
