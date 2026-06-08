# frozen_string_literal: true

# PDF report preferences — lets the parent choose which sections appear in the
# PDFs they share with the pediatrician (PRD §3.8.2 "Genitore sceglie cosa
# includere"). Backed by the User#preferences JSONB store, configured from the
# Settings → "Report PDF" sub-page, and read back by the report aggregators at
# generation time.
#
# Every toggle defaults ON (opt-out): an unset preference must preserve the
# pre-feature behaviour of rendering every section, so no data backfill is
# needed when this ships.
module User::ReportPreferences
  extend ActiveSupport::Concern

  # Optional sections of the growth (pediatrician) report, in render order.
  # Header + footer are structural and always included. Must stay in sync with
  # ReportDataAggregator::SELECTABLE_SECTIONS (guarded by a model test).
  PEDIATRICIAN_SECTIONS = %i[
    general_info
    measurements
    development
    questionnaires
    pediatrician_questions
    notes
  ].freeze

  # store_accessor keys: one boolean per optional growth-report section, plus
  # the stage report's question-detail toggle.
  PEDIATRICIAN_SECTION_KEYS = PEDIATRICIAN_SECTIONS.map { |section| :"pdf_pediatrician_#{section}" }.freeze
  STAGE_KEYS = %i[pdf_stage_question_details].freeze
  BOOLEAN_KEYS = (PEDIATRICIAN_SECTION_KEYS + STAGE_KEYS).freeze

  included do
    store_accessor :preferences, *BOOLEAN_KEYS

    # Generate the boolean accessor pair for each key: cast writes to a real
    # boolean, and read nil (never set) as true. Mirrors User::Notifiable's
    # hand-written accessors. `super` must be explicit inside define_method.
    BOOLEAN_KEYS.each do |key|
      define_method(key) do
        value = super()
        return true if value.nil?
        value
      end

      define_method(:"#{key}=") do |value|
        super(ActiveModel::Type::Boolean.new.cast(value))
      end
    end
  end

  # The growth-report sections currently enabled, in render order — passed to
  # ReportDataAggregator as its section allowlist.
  def pdf_pediatrician_sections
    PEDIATRICIAN_SECTIONS.select { |section| public_send(:"pdf_pediatrician_#{section}") }
  end
end
