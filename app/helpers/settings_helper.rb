# frozen_string_literal: true

module SettingsHelper
  # Family display title for the family tab — renders as "Famiglia <surname>".
  # Falls back to the account name when the user has no surname yet.
  def family_display_name(user, account)
    user.last_name.presence || account.name
  end

  # Section wrapper used in the configuration tab — overline title above a
  # bordered card body that holds .shuby-settings-row children.
  def settings_section_group(title:, &block)
    tag.section(class: "shuby-settings-section") do
      concat tag.h2(title, class: "shuby-settings-section-title")
      concat tag.div(class: "shuby-settings-section-body", &block)
    end
  end

  # Single row: label on the left, optional right-aligned value, trailing
  # chevron. Renders as <a> when href is given (Email, Password, Language,
  # legal links). Set destructive: true to colour the label Fucsia-700.
  def settings_row(label:, href: nil, value: nil, destructive: false, **link_data)
    classes = ["shuby-settings-row"]
    classes << "shuby-settings-row--destructive" if destructive

    body = capture do
      concat tag.span(label, class: "shuby-settings-row__label")
      concat tag.span(value, class: "shuby-settings-row__value") if value.present?
      concat render_svg("shuby/icons/icon-chevron-right", size: :sm, decorative: true, class: "shuby-settings-row__chevron")
    end

    if href.present?
      link_to href, class: classes.join(" "), **link_data do
        body
      end
    else
      tag.div(body, class: classes.join(" "))
    end
  end

  # Row chrome wrapping a button_to — used for sign-out, delete-account,
  # data-export. Same visual shell as settings_row but POST/DELETE under
  # the hood. data: hash flows through to button_to.
  def settings_button_row(label:, url:, method: :post, destructive: false, standalone: false, **data_attrs)
    classes = ["shuby-settings-row", "shuby-settings-row--button"]
    classes << "shuby-settings-row--destructive" if destructive
    classes << "shuby-settings-row--standalone" if standalone

    button_to url, method: method, class: classes.join(" "), data: data_attrs.delete(:data) do
      concat tag.span(label, class: "shuby-settings-row__label")
      concat render_svg("shuby/icons/icon-chevron-right", size: :sm, decorative: true, class: "shuby-settings-row__chevron")
    end
  end

  # Toggle row — auto-submits a single-attribute boolean form. Defaults to
  # settings_privacy_path (the configuration-tab toggles); pass url: to point a
  # toggle at a different settings endpoint (e.g. settings_pdf_path). Reuses the
  # project convention of an sr-only checkbox inside .shuby-toggle whose onchange
  # calls requestSubmit().
  def settings_toggle_row(label:, attribute:, model: current_user, url: settings_privacy_path)
    form_with(model: model, url: url, method: :patch, html: {class: "shuby-settings-row"}) do |form|
      concat tag.span(label, class: "shuby-settings-row__label")
      concat(tag.label(class: "shuby-toggle shrink-0") do
        concat form.check_box(attribute, class: "sr-only", onchange: "this.form.requestSubmit()")
        concat tag.span("", class: "shuby-toggle-knob", "aria-hidden": true)
      end)
    end
  end
end
