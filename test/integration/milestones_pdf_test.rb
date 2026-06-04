# frozen_string_literal: true

require "test_helper"

# Per-stage PDF download icon on the milestones (Tappe) accordion.
# Guards two review findings:
#   NC1 — the icon must live OUTSIDE <details> so it stays visible when a band is
#         collapsed (a closed <details> hides every non-summary child).
#   NC3 — active (blue link) when the band has ≥1 completed area, disabled (grey
#         span) at 0/N.
class MilestonesPdfTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    sign_in @user
    switch_account(@account)
    # sophia (~2 months): current band mese_3 has 0 completed → disabled icon;
    # past band sett_1 has completed sessions → active link.
    get child_path(@child, tab: "milestones")
    assert_response :success
  end

  test "renders an active PDF link for a band with completions" do
    assert_select "a.shuby-milestones-band-pdf[href*=?]", "/stage-reports/"
  end

  test "renders a disabled PDF icon for a 0/N band" do
    assert_select "span.shuby-milestones-band-pdf.shuby-milestones-band-pdf-disabled"
  end

  test "the PDF icon lives outside <details> so it survives collapse (NC1)" do
    # Not a descendant of <details> — otherwise a collapsed band would hide it.
    assert_select "details .shuby-milestones-band-pdf", false,
      "PDF icon must not be inside <details> (would be hidden when collapsed)"
    # It sits in the relative wrapper alongside <details>.
    assert_select ".shuby-milestones-band-wrap .shuby-milestones-band-pdf"
  end

  test "the PDF icon is not inside the toggling <summary>" do
    assert_select "summary .shuby-milestones-band-pdf", false
  end
end
