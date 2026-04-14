module ApplicationHelper
  # Explicitly include ImagesHelper so our render_svg (with size/width/height
  # support) wins over Jumpstart's SvgHelper. The engine injects SvgHelper via
  # config.to_prepare after app helpers load, so we need ApplicationHelper
  # (highest precedence in the view helper chain) to re-assert our version.
  include ImagesHelper
end
