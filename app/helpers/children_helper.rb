# frozen_string_literal: true

module ChildrenHelper
  # Ordered label/value pairs for the "Informazioni" card on /children/:id (Figma node 434:13573).
  # Each entry maps to one .shuby-info-row. Nil values are rendered as em-dashes by the row partial.
  def child_info_rows(child)
    hp = child.health_profile
    [
      [t("children.show.field.name"), child.display_name],
      [t("children.show.field.birth_date"), (l(child.birth_date, format: :short_dotted) if child.birth_date)],
      [t("children.show.field.gestational_weeks"), child.gestational_weeks],
      [t("children.show.field.sex_at_birth"), (t("children.sex.#{child.sex}") if child.sex.present?)],
      [t("children.show.field.birth_weight_grams"), hp&.birth_weight_grams],
      [t("children.show.field.birth_height_cm"), hp&.birth_height_cm]
    ]
  end
end
