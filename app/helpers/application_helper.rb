module ApplicationHelper
  # Explicitly include ImagesHelper so our render_svg (with size/width/height
  # support) wins over Jumpstart's SvgHelper. The engine injects SvgHelper via
  # config.to_prepare after app helpers load, so we need ApplicationHelper
  # (highest precedence in the view helper chain) to re-assert our version.
  include ImagesHelper

  # Drives the View Transitions CSS (see view_transitions.css). Views opt into
  # non-default animations via `<% content_for :page_type, "detail" %>`.
  # Buckets: "root" (default crossfade), "detail"/"wizard" (iOS-style slide),
  # "immersive" (no Turbo VT — for screens with custom Stimulus animations).
  def page_transition_type
    content_for(:page_type).presence || "root"
  end
end
