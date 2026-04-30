# frozen_string_literal: true

class ArchiveFavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content

  def create
    authorize ArchiveFavorite
    current_user.archive_favorites.find_or_create_by(archive_content: @content)

    respond_to do |format|
      format.turbo_stream { render_favorite_button(true) }
      format.html { redirect_back fallback_location: archive_index_path }
    end
  end

  def destroy
    authorize ArchiveFavorite
    current_user.archive_favorites.find_by(archive_content: @content)&.destroy

    respond_to do |format|
      format.turbo_stream { render_favorite_button(false) }
      format.html { redirect_back fallback_location: archive_index_path }
    end
  end

  private

  def set_content
    @content = ArchiveContent.published.find(params[:archive_id])
  end

  def render_favorite_button(favorited)
    variant = (params[:variant].presence || "default").to_sym
    base_id = "favorite_archive_content_#{@content.id}"
    streams = [
      turbo_stream.replace(
        base_id,
        partial: "archive/favorite_button",
        locals: {content: @content, favorited: favorited, variant: variant}
      )
    ]
    if variant == :outlined
      streams << turbo_stream.replace(
        "#{base_id}_sticky",
        partial: "archive/favorite_button",
        locals: {content: @content, favorited: favorited, variant: variant, frame_suffix: :sticky, inline: true}
      )
    end
    render turbo_stream: streams
  end
end
