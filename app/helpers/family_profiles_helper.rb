# frozen_string_literal: true

module FamilyProfilesHelper
  def selectable_radio(form:, field:, value:, label:)
    tag.label(class: "relative cursor-pointer") do
      form.radio_button(field, value, class: "peer sr-only") +
        tag.span(label, class: "block w-full py-3 px-3 text-center rounded-xl border-2 border-gray-200
                    peer-checked:border-[var(--color-shuby-blue-500)] peer-checked:bg-[var(--color-shuby-blue-50)]
                    hover:border-gray-300 transition-all shuby-p2 text-gray-700 dark:text-gray-300")
    end
  end

  def selectable_checkbox(name:, value:, checked:, label:, id:, full_width: false)
    alignment = full_width ? "" : "text-center "
    tag.label(class: "relative cursor-pointer") do
      check_box_tag(name, value, checked, class: "peer sr-only", id: id) +
        tag.span(label, class: "block w-full py-3 px-3 #{alignment}rounded-xl border-2 border-gray-200
                    peer-checked:border-[var(--color-shuby-blue-500)] peer-checked:bg-[var(--color-shuby-blue-50)]
                    hover:border-gray-300 transition-all shuby-p2 text-gray-700 dark:text-gray-300")
    end
  end
end
