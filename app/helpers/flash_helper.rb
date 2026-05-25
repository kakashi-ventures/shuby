module FlashHelper
  # Flash set as Hashes are used for toasts

  ICONS = {
    alert: "shuby/icons/icon-alarm",
    notice: "shuby/icons/icon-tips",
    success: "shuby/icons/icon-bookmark-filled",
    default: "shuby/icons/icon-tips"
  }.freeze

  def flash_icon(icon_name, css_class: nil)
    path = ICONS[icon_name]
    return unless path

    render_svg(path, size: :md, decorative: true, class: css_class)
  end

  def alert
    value = super
    value unless value.is_a?(Hash)
  end

  def notice
    value = super
    value unless value.is_a?(Hash)
  end

  def toasts
    flash.select { |k, v| v.is_a?(Hash) }
  end

  TOAST_LEVELS = {
    notice: {dismiss_after: 4000},
    alert: {icon_name: :alert, dismiss_after: 6000}
  }.freeze

  def flash_toast_attrs(level, message)
    TOAST_LEVELS.fetch(level).merge(title: message, dismissable: true)
  end

  def banner(message: nil, classes: "banner-info", icon_name: nil, &block)
    icon = flash_icon(icon_name, css_class: "icon-#{icon_name}") if icon_name
    block ||= ->(tag_builder) { icon.to_s + tag.p(sanitize(message)) }
    tag.div class: class_names("banner", classes), role: "alert", &block
  end

  def impersonation_banner
    return if current_user == true_user

    banner classes: "banner-impersonate" do
      tag.span("Logged in as <b>#{link_to "#{current_user.name} (#{current_user.email})", main_app.madmin_user_path(current_user), class: "underline"}</b>".html_safe) +
        button_to("Log out", main_app.madmin_user_impersonate_path(current_user), method: :delete, form_class: "inline-block", class: "btn btn-secondary btn-small")
    end
  end
end
