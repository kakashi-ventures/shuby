# frozen_string_literal: true

# Controller for Archivio (Archive) educational content
# Displays browsable educational materials for parents about child development
class ArchiveController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: [:show]

  # GET /archivio
  # Lists all published archive content organized by sections
  def index
    if params[:type].present?
      # Filtered view - show all content of a specific type
      load_filtered_content
    else
      # Home view - show sectioned content
      load_sectioned_content
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /archivio/:id
  # Displays a single archive content item
  def show
  end

  private

  def base_scope
    ArchiveContent.published
  end

  # Load content for the sectioned home view
  def load_sectioned_content
    @articles = base_scope.articles.ordered.limit(4)
    @consigli = base_scope.where(content_type: [:book, :tip]).ordered.limit(4)
    @activities = base_scope.games.ordered.limit(4)
    @sectioned_view = true
  end

  # Load filtered content for type-specific views
  def load_filtered_content
    @contents = base_scope
    @active_type = params[:type] if ArchiveContent.content_types.key?(params[:type])
    @contents = @contents.by_type(@active_type) if @active_type

    # Filter by age range
    if params[:age].present?
      @contents = @contents.for_age(params[:age].to_i)
      @selected_age = params[:age].to_i
    end

    # Filter by category
    if params[:category].present?
      @contents = @contents.where(category: params[:category])
      @selected_category = params[:category]
    end

    @contents = @contents.ordered

    # Get unique categories for filter dropdown
    @categories = ArchiveContent.published
                                .distinct
                                .pluck(:category)
                                .compact
                                .sort
    @sectioned_view = false
  end

  def set_content
    @content = ArchiveContent.published.find_by(slug: params[:id])
    @content ||= ArchiveContent.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to archive_index_path, alert: t("archive.not_found")
  end
end
