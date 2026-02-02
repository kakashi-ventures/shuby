# frozen_string_literal: true

module User::DataSharingConsent
  extend ActiveSupport::Concern

  included do
    store_accessor :preferences, :data_sharing_consent
  end

  def data_sharing_consent=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  def data_sharing_consented?
    data_sharing_consent == true
  end
end
