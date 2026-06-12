# frozen_string_literal: true

require "application_system_test_case"

# Tappa (milestone) questionnaire overlay — full-screen takeover opened from
# the Timeline (and Dashboard) milestone cards via
# `questionnaire_overlay_controller#openWithFrame`.
#
# Regression coverage for the focus-trap scroll bug: opening the overlay used
# to scroll the caller page behind it. Root cause was the shared
# `src/focus_trap` helper focusing the first control (the overlay close button,
# which sits atop a sheet still animating in from `translateY(100%)`, i.e.
# off-screen) WITHOUT `{ preventScroll: true }` — so the browser scrolled the
# caller page to "reveal" it. It fired once per open (the first story), matching
# the reported symptom.
#
# NOTE ON ENGINE: the page-scroll-on-focus only reproduces in WebKit (Shuby's
# iOS WKWebView runtime). Headless Chrome (Blink) does NOT scroll for a focusable
# inside a `position: fixed`/transformed overlay — in fact it declines to move
# focus there at open time — so the bug is invisible through the real overlay
# under Selenium. We therefore guard the ROOT CAUSE directly: the shared
# `activateFocusTrap` must never scroll the page when it moves focus to an
# off-screen control. That contract reproduces deterministically in Blink (a
# normal-flow off-screen control IS scrolled-to without `preventScroll`) and
# covers every overlay that imports the helper.
class QuestionnaireOverlaySystemTest < ApplicationSystemTestCase
  setup do
    # Emma lives in user one's personal account, so no switch_account is needed
    # (switch_account's extra redirect trips the Warden session helper under
    # Selenium — see MeasurementOverlaySystemTest).
    @user = users(:one)
    @child = children(:emma)
    # Pin her age to a band that HAS fixture questionnaires. age_in_months floors
    # days/30.44, so whole-N-months-ago dates land on a sparse gap band (6mo →
    # "Mese 5", which has no fixture). 200 days → age 6 → current band mese_6,
    # which the fixtures define for all 5 areas. With no prior session her
    # current-band cards are interactive "start" triggers that open the overlay
    # (timeline_card_destination → overlay: true).
    @child.update!(birth_date: 200.days.ago.to_date)
    login_as @user, scope: :user
  end

  OVERLAY = "[data-questionnaire-overlay-target='overlay']"
  # Interactive current-band cards render as <a> links carrying the openWithFrame
  # action; past/future cards are plain <div>s, so an <a> with this class is a
  # trigger.
  TRIGGER = "a.shuby-milestone-card"

  # REGRESSION GUARD (root cause). Drives the real shared `activateFocusTrap` and
  # asserts it does not scroll the page when focusing a control below the fold —
  # exactly what dragged the caller page behind the tappa overlay on open.
  test "activateFocusTrap does not scroll the caller page when focusing an off-screen control" do
    visit child_development_stages_path(@child) # any page in the importmap context

    result = page.evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1];
      (async () => {
        try {
          const { activateFocusTrap } = await import("src/focus_trap");
          const host = document.createElement("div");
          const spacer = document.createElement("div");
          spacer.style.height = "5000px";               // make the page scrollable
          const btn = document.createElement("button");
          btn.textContent = "below the fold";           // sits ~5000px down, off-screen
          host.appendChild(spacer);
          host.appendChild(btn);
          document.body.appendChild(host);

          window.scrollTo(0, 0);
          const before = window.scrollY;
          const release = activateFocusTrap(host);       // focuses btn (first focusable)
          const after = window.scrollY;
          const focused = document.activeElement === btn;
          release();
          host.remove();
          done({ before, after, focused });
        } catch (e) {
          done({ error: String(e) });
        }
      })();
    JS

    assert_nil result["error"], "focus_trap harness threw: #{result["error"]}"
    assert result["focused"], "precondition: activateFocusTrap should have moved focus to the off-screen control"
    assert_equal result["before"], result["after"],
      "activateFocusTrap scrolled the page (#{result["before"]} → #{result["after"]}) when focusing an off-screen control"
  end

  # Integration smoke: the real tappa overlay wiring opens and closes.
  test "tappa overlay opens with the open modifier and closes on escape" do
    visit child_development_stages_path(@child)

    # Overlay is present but closed before interaction.
    assert_equal "true", find(OVERLAY, visible: :all)["aria-hidden"]

    find(TRIGGER, match: :first).click
    assert_selector "#{OVERLAY}.shuby-questionnaire-overlay--open"

    find("body").send_keys(:escape)
    assert_no_selector "#{OVERLAY}.shuby-questionnaire-overlay--open"
  end
end
