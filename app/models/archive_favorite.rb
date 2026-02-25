# frozen_string_literal: true

class ArchiveFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :archive_content

  validates :archive_content_id, uniqueness: {scope: :user_id}
end
