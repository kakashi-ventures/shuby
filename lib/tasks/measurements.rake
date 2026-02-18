# frozen_string_literal: true

namespace :measurements do
  desc "Recalculate WHO percentiles for all measurements"
  task recalculate_percentiles: :environment do
    updated = 0
    Measurement.includes(:child).find_each do |measurement|
      old_percentile = measurement.percentile
      new_percentile = PercentileCalculator.call(measurement: measurement, child: measurement.child)
      if old_percentile != new_percentile
        measurement.update_column(:percentile, new_percentile)
        updated += 1
      end
    end
    puts "Updated #{updated} measurement percentiles."
  end
end
