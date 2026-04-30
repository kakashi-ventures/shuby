# frozen_string_literal: true

require "application_system_test_case"

# Regression test: the WHO percentile chart on the measurement detail page
# must survive a unit-toggle reload. The toggle calls Turbo.visit on the
# same URL, which uses morph (see `turbo_refreshes_with method: :morph` in
# _head.html.erb). Without `data-turbo-permanent` on the chart wrapper,
# morph reverts the canvas's runtime width/height attributes back to the
# server-rendered defaults, leaving Chart.js's drawing at 300×150 pixels
# — visible to the user as a half-empty chart.
class MeasurementChartSystemTest < ApplicationSystemTestCase
  CANVAS_DEFAULT_WIDTH = 300

  setup do
    @user = users(:one)
    @child = children(:emma)
    login_as @user, scope: :user
    @weight = Measurement.create!(
      child: @child,
      measurement_type: :weight,
      value: 7000,
      measured_at: 5.days.ago,
      percentile: 50
    )
  end

  test "chart canvas survives unit toggle (Turbo morph)" do
    visit child_measurement_path(@child, @weight)

    # Initial render — wait for Chart.js + rAF deferral to finish.
    assert_canvas_drawn
    initial_width = canvas_pixel_width
    assert_operator initial_width, :>, CANVAS_DEFAULT_WIDTH,
      "chart should render wider than the 300px default on initial load"

    # First toggle: gr → lb. Triggers PATCH + Turbo.visit (morph).
    find(".shuby-unit-toggle").click
    wait_for_morph_settle
    assert_operator canvas_pixel_width, :>, CANVAS_DEFAULT_WIDTH,
      "chart canvas reverted to default 300px width after morph reload — " \
      "ensure data-turbo-permanent stays on _growth_chart.html.erb wrapper"

    # Second toggle: lb → gr. Same morph path, opposite direction.
    find(".shuby-unit-toggle").click
    wait_for_morph_settle
    assert_operator canvas_pixel_width, :>, CANVAS_DEFAULT_WIDTH,
      "chart canvas reverted on toggle-back"
  end

  test "unit toggle does NOT trigger a page navigation" do
    visit child_measurement_path(@child, @weight)
    assert_canvas_drawn

    # Tag the document so we can detect a full reload by its absence afterwards.
    page.evaluate_script("window.__shubyToggleSentinel = true")

    find(".shuby-unit-toggle").click
    sleep 0.3 # plenty for client-side flip

    sentinel = page.evaluate_script("window.__shubyToggleSentinel === true")
    assert sentinel,
      "page reloaded on unit toggle — the toggle should be a pure client-side " \
      "flip with a fire-and-forget PATCH, no Turbo.visit"
  end

  test "chart y-axis title reflects unit toggle (Peso (kg) ↔ Peso (lb))" do
    visit child_measurement_path(@child, @weight)
    assert_canvas_drawn

    # Initial: metric.
    assert_equal "Peso (kg)", chart_y_axis_title

    # Toggle to imperial.
    find(".shuby-unit-toggle").click
    wait_for_morph_settle
    assert_equal "Peso (lb)", chart_y_axis_title,
      "y-axis title did not update to imperial after unit toggle — " \
      "ensure unitSystemValueChanged re-renders the chart with converted data"

    # Toggle back to metric.
    find(".shuby-unit-toggle").click
    wait_for_morph_settle
    assert_equal "Peso (kg)", chart_y_axis_title
  end

  private

  # Reads the y-axis title text directly from the live Chart.js instance.
  # This is the source of truth — what the user actually sees as the axis label.
  def chart_y_axis_title
    page.evaluate_script(<<~JS)
      (() => {
        const c = document.querySelector("canvas[data-growth-chart-target='canvas']")
        return c?.__shubyChart?.options?.scales?.y?.title?.text || ""
      })()
    JS
  end

  # Polls for the canvas to have a non-default pixel width. Chart.js applies
  # its sizing inside a requestAnimationFrame after Stimulus connects, so
  # the canvas is briefly at the default 300×150 before the chart draws.
  def assert_canvas_drawn
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until canvas_pixel_width.to_i > CANVAS_DEFAULT_WIDTH
    end
  rescue Timeout::Error
    flunk "canvas never drew above the default #{CANVAS_DEFAULT_WIDTH}px width"
  end

  def canvas_pixel_width
    page.evaluate_script(<<~JS)
      document.querySelector("canvas[data-growth-chart-target='canvas']")?.width || 0
    JS
  end

  # Toggle is now a pure client-side flip — no network wait required.
  # A short sleep gives the chart's value-changed callback + re-render
  # time to settle; ~150ms is empirically more than enough.
  def wait_for_morph_settle
    sleep 0.15
  end
end
